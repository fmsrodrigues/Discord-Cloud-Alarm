resource "null_resource" "install_got_layer_deps" {
  triggers = {
    layer_build = filemd5("${local.layers_path}/got/nodejs/package.json"),
  }

  provisioner "local-exec" {
    working_dir = "${local.layers_path}/got/nodejs"
    command     = "npm install --production"
  }
}

data "archive_file" "got_layer" {
  output_path = "./../files/got-layer.zip"
  type        = "zip"
  source_dir  = "${local.layers_path}/got"

  depends_on = [
    null_resource.install_got_layer_deps
  ]
}

resource "aws_lambda_layer_version" "got" {
  layer_name          = "got-layer"
  description         = "got: ^12.1.0"
  filename            = data.archive_file.got_layer.output_path
  source_code_hash    = data.archive_file.got_layer.output_base64sha256
  compatible_runtimes = ["nodejs16.x"]
}

resource "null_resource" "install_dotenv_layer_deps" {
  triggers = {
    layer_build = filemd5("${local.layers_path}/dotenv/nodejs/package.json"),
  }

  provisioner "local-exec" {
    working_dir = "${local.layers_path}/dotenv/nodejs"
    command     = "npm install --production"
  }
}

data "archive_file" "dotenv_layer" {
  output_path = "./../files/dotenv-layer.zip"
  type        = "zip"
  source_dir  = "${local.layers_path}/dotenv"

  depends_on = [
    null_resource.install_dotenv_layer_deps
  ]
}

resource "aws_lambda_layer_version" "dotenv" {
  layer_name          = "dotenv-layer"
  description         = "dotenv: ^16.0.1"
  filename            = data.archive_file.dotenv_layer.output_path
  source_code_hash    = data.archive_file.dotenv_layer.output_base64sha256
  compatible_runtimes = ["nodejs16.x"]
}

resource "null_resource" "install_regenerator_runtime_layer_deps" {
  triggers = {
    layer_build = filemd5("${local.layers_path}/regenerator-runtime/nodejs/package.json"),
  }

  provisioner "local-exec" {
    working_dir = "${local.layers_path}/regenerator-runtime/nodejs"
    command     = "npm install --production"
  }
}

data "archive_file" "regenerator_runtime_layer" {
  output_path = "./../files/regenerator-runtime-layer.zip"
  type        = "zip"
  source_dir  = "${local.layers_path}/regenerator-runtime"

  depends_on = [
    null_resource.install_regenerator_runtime_layer_deps
  ]
}

resource "aws_lambda_layer_version" "regenerator_runtime" {
  layer_name          = "regenerator-runtime-layer"
  description         = "regenerator-runtime: ^12.1.0"
  filename            = data.archive_file.regenerator_runtime_layer.output_path
  source_code_hash    = data.archive_file.regenerator_runtime_layer.output_base64sha256
  compatible_runtimes = ["nodejs16.x"]
}
