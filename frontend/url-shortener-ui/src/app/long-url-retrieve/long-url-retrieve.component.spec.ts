import { ComponentFixture, TestBed } from '@angular/core/testing';

import { LongUrlRetrieveComponent } from './long-url-retrieve.component';

describe('LongUrlRetrieveComponent', () => {
  let component: LongUrlRetrieveComponent;
  let fixture: ComponentFixture<LongUrlRetrieveComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [LongUrlRetrieveComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(LongUrlRetrieveComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
