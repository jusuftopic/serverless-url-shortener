import { Component } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { ShortenUrlComponent } from './shorten-url/shorten-url.component';
import { LongUrlRetrieveComponent } from './long-url-retrieve/long-url-retrieve.component';

@Component({
  selector: 'app-root',
  imports: [ ShortenUrlComponent, LongUrlRetrieveComponent],
  templateUrl: './app.component.html',
  styleUrl: './app.component.scss'
})
export class AppComponent {
  title = 'url-shortener-ui';
}
