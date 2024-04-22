import { Controller, Get, Post, UploadedFile, UseInterceptors } from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { Express } from 'express';
import { memoryStorage } from 'multer';
import { AppService } from './app.service';

@Controller('images')
export class AppController {
    constructor(private readonly appService: AppService) {}

    @Get()
    async getImages() {
        return await this.appService.getImages();
    }

    @Post()
    @UseInterceptors(
        FileInterceptor('image', {
            storage: memoryStorage(),
            limits: { fieldSize: 5000000 },
        })
    )
    async uploadImage(@UploadedFile() image: Express.Multer.File) {
        return await this.appService.uploadImage(image);
    }
}
