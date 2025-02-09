import { Component } from '@angular/core';
import { MatToolbar } from '@angular/material/toolbar';
import { MatCard } from '@angular/material/card';
import { MatFormField, MatLabel } from '@angular/material/form-field';
import { MatButton } from '@angular/material/button';
import { MatInput } from '@angular/material/input';
import { NgIf } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { HttpClient, HttpClientModule } from '@angular/common/http';
import { MatSnackBar } from '@angular/material/snack-bar';

@Component({
  selector: 'app-shorten-url',
  imports: [
    MatToolbar,
    MatCard,
    MatFormField,
    MatButton,
    MatInput,
    NgIf,
    FormsModule,
    MatLabel,
    HttpClientModule
  ],
  templateUrl: './shorten-url.component.html',
  styleUrl: './shorten-url.component.scss'
})
export class ShortenUrlComponent {
  urlToShorten: string = '';
  shortenedUrl: string = '';

  constructor(private http: HttpClient, private snackBar: MatSnackBar) {}

  shortenUrl() {
    if (!this.urlToShorten) {
      this.snackBar.open('Please enter a URL!', 'Close', { duration: 3000 });
      return;
    }

    this.http
      .post<{ shortUrl: string }>('https://your-api-url/shorten', { url: this.urlToShorten })
      .subscribe(
        (response) => {
          this.shortenedUrl = response.shortUrl;
        },
        (error) => {
          this.snackBar.open('Failed to shorten URL', 'Close', { duration: 3000 });
        }
      );
  }

  copyToClipboard() {
    navigator.clipboard.writeText(this.shortenedUrl);
    this.snackBar.open('Copied to clipboard', 'Close', { duration: 3000 });
  }
}
