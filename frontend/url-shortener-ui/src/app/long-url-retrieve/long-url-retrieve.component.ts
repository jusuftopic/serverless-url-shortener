import { Component } from '@angular/core';
import { MatToolbar } from '@angular/material/toolbar';
import { MatCard } from '@angular/material/card';
import { MatFormField } from '@angular/material/form-field';
import { MatInput } from '@angular/material/input';
import { FormsModule } from '@angular/forms';
import { MatButton } from '@angular/material/button';
import { NgIf } from '@angular/common';
import { HttpClient } from '@angular/common/http';

@Component({
  selector: 'app-long-url-retrieve',
  imports: [
    MatToolbar,
    MatCard,
    MatFormField,
    MatInput,
    FormsModule,
    MatButton,
    NgIf
  ],
  templateUrl: './long-url-retrieve.component.html',
  styleUrl: './long-url-retrieve.component.scss'
})
export class LongUrlRetrieveComponent {
  shortUrl: string = '';
  longUrl: string = '';

  constructor(private http: HttpClient, private snackBar: MatSnackBar) {}


  getLongUrl() {
    if (!this.shortUrl) {
      this.snackBar.open('Please enter a short URL!', 'Close', { duration: 3000 });
      return;
    }

    this.http
      .get<{ longUrl: string }>(`https://your-api-url/long_url/${this.shortUrl}`)
      .subscribe(
        (response) => {
          this.longUrl = response.longUrl;
        },
        (error) => {
          this.snackBar.open('Failed to retrieve long URL', 'Close', { duration: 3000 });
        }
      );
  }
}
