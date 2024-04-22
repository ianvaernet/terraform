import { HttpClient } from '@angular/common/http';
import { Component, OnInit } from '@angular/core';
import { env } from '../environments/environment';

@Component({
    selector: 'app-root',
    standalone: true,
    templateUrl: './app.component.html',
    styleUrl: './app.component.scss',
})
export class AppComponent implements OnInit {
    imageToUpload?: File;
    imageToUploadUrl?: string;
    imagesInGallery: Image[] = [];

    constructor(private httpClient: HttpClient) {}

    ngOnInit(): void {
        this.httpClient.get<Image[]>(`${env.API_URL}/images`).subscribe((data) => {
            data.forEach(({ id, url }) => {
                this.imagesInGallery.push({
                    id,
                    url,
                });
            });
        });
    }

    setImage(event: any) {
        this.imageToUpload = event.target.files[0];
        this.imageToUploadUrl = URL.createObjectURL(this.imageToUpload!);
    }

    uploadImage() {
        const formData = new FormData();
        formData.append('image', this.imageToUpload!);
        this.httpClient.post<Image>(`${env.API_URL}/images`, formData).subscribe((data) => {
            this.imagesInGallery.push(data);
        });
        this.imageToUpload = undefined;
        this.imageToUploadUrl = undefined;
    }
}

type Image = {
    id: string;
    url: string;
};
