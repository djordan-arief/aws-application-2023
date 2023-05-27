# Week 5 — DynamoDB and Serverless Caching

# instruction github link
https://github.com/omenking/aws-bootcamp-cruddur-2023/blob/week-5/journal/week5.md

# Security consideration: AWS Side
- Create a DynamoDB table in the right region
- Create a VPC endpoints
- Enable AWS Cloudtrail 
- Compliance standard: store user's data in the correct region

# Security consideration: Application side
- Use the appropriate authentication to connect to DynamoDB
- Use IAM roles 
- Not have DynamoDB be accessible from the internet
- Client side encryption 

