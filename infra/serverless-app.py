import json
import boto3
from collections import Counter
import urllib.parse

def lambda_handler(event, context):
    body = json.loads(event['body'])
    text = body['text']
    
    # Find top 10 most frequent words
    words = text.split()
    word_counts = Counter(words)
    top_words = word_counts.most_common(10)
    
    # Create JSON content
    result = {word: count for word, count in top_words}
    
    # Save to S3
    s3 = boto3.client('s3')
    bucket_name = 'serverless-app-lambda'
    file_name = 'top_words.json'
    s3.put_object(Bucket=bucket_name, Key=file_name, Body=json.dumps(result), ServerSideEncryption='AES256')
    
    # Generate URL
    url = s3.generate_presigned_url(
        ClientMethod='get_object',
        Params={'Bucket': bucket_name, 'Key': file_name},
        ExpiresIn=3600
    )
    
    return {
        'statusCode': 200,
        'body': json.dumps({'url': url}),
        'headers': {
            'Content-Type': 'application/json'
        }
    }
