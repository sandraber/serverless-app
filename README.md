# MVP serverless-app

This README provides an overview of the Minimum Viable Product (MVP) of a serverless architecture utilizing Amazon Web Services (AWS). The architecture consists of API Gateway for handling HTTP requests, Lambda functions for processing data with Python, and S3 for storing files and generating pre-signed URLs.

# Architecture

![arch](arch.drawio.png)

# Components

## API Gateway

- Acts as the entrypoint for incoming HTTP requests.
- Routes requests to appropriate Lambda functions.
- Provides features like request validation, response transformation, and rate limiting.

## Lambda Functions

- Written in Python, these functions handle the business logic of the application.
- Receive data from API Gateway, process it, and interact with other AWS services as needed.
- Specifically, one Lambda function will process incoming text data, extract the top 10 most frequent words, and to store the result in an S3 bucket needs a IAM role with enough permissions in the bucket.

## S3

- Stores the processed data, such as the JSON file containing the top 10 most frequent words.
- Generates pre-signed URLs to allow secure access to the stored files for a limited time period.
- Ensure that every object updated to the bucket is encrypted
- Versioning enabled
- Only TLS connections are accepted
- Only TLS1.2 or higher for all connections


# MVP Workflow

## API Gateway Configuration

- Set up API Gateway endpoints to receive incoming POST requests.
- Configure request validation and integration with Lambda functions.

## Lambda Function

- Create a Lambda function written in Python to process incoming text data.
- Utilize libraries like boto3 to interact with S3 for file storage.
- Generate pre-signed URLs for accessing the stored files securely.

## S3 Bucket Configuration

- Create an S3 bucket to store the processed data.
- Configure bucket policies and permissions to allow access from the Lambda function.

# Deployment Steps

## Prerequisites

- AWS account with appropriate permissions.
- AWS CLI installed and configured.
- Terraform installed for managing infrastructure as code (optional but recommended).

## Deploying Infrastructure

- Clone the repo in local:

```bash
git clone git@github.com:sandraber/serverless-app.git
```

- Use Terraform code in `infra` folder to provision the necessary resources (API Gateway, Lambda function, S3 bucket), changing the backend, and the profile, and bucket name and region AWS in these files:

 `backend.tf`
```terraform

terraform {
  backend "s3" {
    bucket  = "NAME-OF-YOUR-BUCKET"
    key     = "serverles-app/terraform.tfstate"
    region  = "eu-west-1" # YOUR REGION
    profile = "terraform" # YOUR PROFILE IN AWS CLI.
  }
}
```
 `providers.tf`
```terraform
provider "aws" {
  region              = var.region
  profile             = "terraform" # YOUR PROFILE WITH ADMIN PERMISSIONS IN AWS.
  allowed_account_ids = ["xxxxxxxxx"] ## PUT YOUR ACCOUNT ID

  default_tags {
    tags = {
      Role        = var.project_name
      Provisioner = "Terraform"
    }
  }
}
```
 `terraform.tfvars`
```terraform
project_name = "serverless-app"
region       = "eu-west-1" ## YOUR REGION.
```
- Ensure proper configurations for security, permissions, and resource dependencies.

## Testing

- Test the API endpoints using tools like curl or Postman.

 Example:
```bash
curl -X POST \
  -H "Content-Type: application/json" \
  -d '{ "text": "ma mo ma mo mi me ma mo mi ma ma mo mo me ma mo" }' \
  https://r79ka8n1wl.execute-api.eu-west-1.amazonaws.com/prod/process
```
- Verify that the Lambda function processes data correctly and stores the result in the S3 bucket, name bucket:serverless-app-lambda.
- Test the pre-signed URLs to ensure secure access to the stored files. The URL can be something like:

```bash
https://serverless-app-lambda.s3.amazonaws.com/top_words.json?AWSAccessKeyId=ASIA47CRYLUTTJZRIS3N&Signature=hCGDR08L3evcyn7fQfRJr3QlDsI%3D&x-amz-security-token=IQoJb3JpZ2luX2VjEMf%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FwEaCWV1LXdlc3QtMSJGMEQCIG%2FwRwMYmTqloh%2BI3MGPz3bejkmhGols%2BHynhsacesPoAiBq%2BtN7SbATh%2B4g42JcbHyMvrSsoJgUgP6UhPYuSK%2BA6irsAghgEAAaDDg5MTM3NzE3OTk0MyIMMFXHSBg0zYxO1EvUKskCQ8jNy00aJAxmdmwOWIcLDa80SF5x5xZAU1q%2FeCsim9u49yv8vqSyJd5ev9Nb3ihKMQdb1iOJJvqAyK71ldUnfVBcCj%2F2N3UzyNlVT6x61l7G1xxrTB7agi1dASnrhYQtJ%2FsBo%2BIeWMlVXmycunlV%2BNRucrWt%2FCvHJyENzwULxs1K%2BWyF2m4AmhuWNbY34FLpLN2c6BZY0Xrc0%2B3jS3SRcMUIKUdqLt%2F%2Fns2FarV3kb5rFygYApWkgStr26t2nfqsfCXvDvG%2B7sF63zrrEUyNfzOmVGU8vedDX9kmF8ZlRHN9SIMEt1kCQDiElaCioVArBfxTZYJnajyl9CCd5U6661sOi0a9EUSnVpaABJ1GMQmG28HwYbtZLm0HiOD%2Fkbi5RRMQrvYzl%2Fl9aJGnUXigA4aUOpHHrBaD%2Fv3suzXGYey8%2FCJJCOan6GIw0cehswY6nwEcT8Y0YggQqFRkQjnwN9Po76jGvok7WrRbSxJhxUFzfwp4RKVhucBxETXxnS3KbDW5%2BW7ZJJXi03l1dd8ex0oGgdU7N%2F9DDR4IonVfiyJCs0dPaOlRlmRpxNpLQ1U94oPH73R21tLMKZPIxTBzDRB69MHwy7O5robrffjk7bF5GMvubpODQ4DVl213RedQ48YPClnm3r4a0Pjl%2BwEVnQ0%3D&Expires=1718121146
```

And the downloaded file:

```bash
{"ma": 6, "mo": 6, "mi": 2, "me": 2}
```

# Lambda Function Details
The Python Lambda function processes incoming text data, extracts the top 10 most frequent words, saves the result in a JSON file in an S3 bucket, and generates a pre-signed URL to access the stored file. For detailed information on the function code and workflow, refer to the provided Python code.

# Conclusion
This MVP demonstrates a basic serverless architecture using API Gateway, Lambda, and S3 in AWS. By following the steps outlined in this README, you can deploy a functional system for processing data through HTTP requests, storing results securely, and providing access to the stored files via pre-signed URLs. Further enhancements and optimizations can be implemented based on specific project requirements and use cases, for instance:
 
- By incorporating AWS Cognito authorization into the serverless architecture, this MVP enhances security and control over access to resources. Users must authenticate through Cognito before accessing API Gateway endpoints, ensuring that only authorized users can interact with the system.
- By creating Lifecycle policies ensure that the bucket is not accumulating old data or no current versions.
