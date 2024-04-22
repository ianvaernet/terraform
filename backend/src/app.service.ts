import { DynamoDBClient, PutItemCommand, ScanCommand } from '@aws-sdk/client-dynamodb';
import { PutObjectCommand, S3Client } from '@aws-sdk/client-s3';
import { Injectable } from '@nestjs/common';
import { randomUUID } from 'crypto';

@Injectable()
export class AppService {
    private s3Client: S3Client;
    private dynamoClient: DynamoDBClient;

    constructor() {
        this.s3Client = new S3Client();
        this.dynamoClient = new DynamoDBClient();
    }

    async uploadImage(image: Express.Multer.File) {
        const id = randomUUID();
        const url = `${process.env.S3_BUCKET_URL}/${id}`;
        const dynamoPromise = this.dynamoClient.send(
            new PutItemCommand({
                TableName: process.env.DYNAMODB_TABLE,
                Item: {
                    id: { S: id },
                    url: { S: url },
                },
            })
        );
        const s3Promise = this.s3Client.send(
            new PutObjectCommand({
                Bucket: process.env.S3_BUCKET_NAME,
                Key: id,
                Body: image.buffer,
                ContentLength: image.size,
                ContentType: image.mimetype,
            })
        );
        await Promise.all([dynamoPromise, s3Promise]);
        return { id, url };
    }

    async getImages() {
        const response = await this.dynamoClient.send(
            new ScanCommand({
                TableName: process.env.DYNAMODB_TABLE,
            })
        );
        return response.Items.map((item) => this.parseDynamoItem(item));
    }

    private parseDynamoItem(item: Record<string, any>) {
        return Object.entries(item).reduce((obj, [key, value]) => ({ ...obj, [key]: Object.values(value)[0] }), {});
    }
}
