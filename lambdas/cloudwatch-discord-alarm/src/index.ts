import "dotenv/config";

import { Context, APIGatewayProxyCallback, APIGatewayProxyResult, SNSEvent, SNSEventRecord } from "aws-lambda";

import got from "got";

type SNSMessage = { [key: string]: any };

interface BuildSNSMessageParams {
  snsMessage: SNSMessage;
  from?: string;
}

interface DiscordEmbeddedFields {
  name: string;
  value: string;
  inline?: boolean;
}

export function isSNSMessageAlarm(parsedJson: SNSMessage): boolean {   
  const trigger = parsedJson.Trigger;
  const isAlarm = trigger.Namespace === "AWS/Lambda";

  return isAlarm;
}

export function buildDiscordMessage({ snsMessage, from }: BuildSNSMessageParams): DiscordEmbeddedFields[]  {
  if(!from) {
    const messagesContent: string[] = JSON.stringify(snsMessage).match(/.{1,2000}/g)!;
    if(messagesContent.length > 20) {
      const limitedMessages = messagesContent.slice(0, 20).map((message, index) => {
        return {
          name: `Something not parsed happened. Log fragment: ${index + 1}`,
          value: message
        }
      });

      return [{ name: "Something not parsed happend", value: "message is to long to send" }, ...limitedMessages];
    }

    const messages: DiscordEmbeddedFields[] = messagesContent.map((message, index) => {
      return {
        name: `Something not parsed happened. Log fragment: ${index + 1}`,
        value: message
      }
    })

    return messages;
  };

  return [{
    name: from,
    value: snsMessage.Trigger?.Dimensions[0].value ?? "Not Defined",
    inline: true
  }, {
    name: "Alarm",
    value: snsMessage.AlarmName ?? "Not Defined",
    inline: true
  }, {
    name: "Description",
    value: snsMessage.AlarmDescription ?? "Not Defined",
  }, {
    name: "Old State",
    value: snsMessage.OldStateValue ?? "Not Defined",
    inline: true
  }, {
    name: "Trigger",
    value: snsMessage.Trigger?.MetricName ?? "Not Defined",
    inline: true
  }, {
    name: "Event",
    value: snsMessage.NewStateReason ?? "Not Defined",
    inline: true
  }];
}

export async function sendDiscordMessage(discordMessage: DiscordEmbeddedFields[]) {
  const discord = {
    webhook: process.env.DISCORD_WEBHOOK!,
    username: "AWS Lambda bot",
    avatarUrl: "https://upload.wikimedia.org/wikipedia/commons/e/e9/Amazon_Lambda_architecture_logo.png" ,
    embedsColor: 16711680
  }

  const res = await got.post(discord.webhook, {
    headers: {
      "content-type": "application/json",
    },
    json: {
      username: discord.username,
      avatar_url: discord.avatarUrl,
      content: "Alarm Triggered",
      embeds: [{
        color: discord.embedsColor,
        fields: discordMessage
      }]
    },
  });

  console.log(`Discord response status: ${res.statusCode}`);
  console.log(`Discord response content: ${res.body}`);

  return res;
}

export function handleSNSEventRecords(records: SNSEventRecord[]) {
  const messagesPromise = records.map(async record => {
    const parsedSNSMessage: SNSMessage = JSON.parse(record.Sns.Message);

    const isAlarm = isSNSMessageAlarm(parsedSNSMessage);
    const message = buildDiscordMessage({
      snsMessage:  parsedSNSMessage,
      from: isAlarm ? "AWS Lambda" : undefined,
    });
    return sendDiscordMessage(message);
  });

  return messagesPromise;
}

export async function handler(event: SNSEvent, _context?: Context, _callback?: APIGatewayProxyCallback): Promise<APIGatewayProxyResult> {
  console.log("Event:", event);
  console.log("Context:", _context);

  try {
    if(!process.env.DISCORD_WEBHOOK) {
      throw new Error("DISCORD_WEBHOOK env variable must be set!");
    }

    const discordMessagesReturns = await Promise.allSettled(handleSNSEventRecords(event.Records));

    console.log("All Setteld:", discordMessagesReturns);

    return {
      statusCode: 200,
      body: "All discord messages were sent successfully!"
    };
  } catch (error) {
    console.error(error);
    throw new Error("Something went wrong");
  }
}