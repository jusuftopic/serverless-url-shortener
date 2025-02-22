import { Component } from '@angular/core';
import { MatToolbar } from '@angular/material/toolbar';
import { MatCard } from '@angular/material/card';
import { MatFormField, MatLabel } from '@angular/material/form-field';
import { MatInput } from '@angular/material/input';
import { FormsModule } from '@angular/forms';
import { MatButton } from '@angular/material/button';
import { NgIf } from '@angular/common';
import { HttpClient, HttpClientModule } from '@angular/common/http';
import { MatSnackBar } from '@angular/material/snack-bar';
import { environment } from '../../environments/environment';

@Component({
  selector: 'app-long-url-retrieve',
  imports: [
    MatToolbar,
    MatCard,
    MatFormField,
    MatInput,
    FormsModule,
    MatButton,
    NgIf,
    MatLabel,
    HttpClientModule
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

    this.http.get<{ long_url: string }>(environment.backendBaseUrl + `/${this.shortUrl}`)
      .subscribe({
        next: (response) => this.longUrl = response.long_url,
        error: () => this.snackBar.open('Failed to retrieve long URL', 'Close', { duration: 3000 })
      });
  }
}
