import { TestBed } from '@angular/core/testing';
import { HomePageComponent } from './home-page.component';

describe('TC-TT-PRU-03-02 home page heading', () => {
  it('renders the exact accessible heading Panel Knock', async () => {
    await TestBed.configureTestingModule({
      imports: [HomePageComponent],
    }).compileComponents();

    const fixture = TestBed.createComponent(HomePageComponent);
    fixture.detectChanges();

    const headings = fixture.nativeElement.querySelectorAll('h1');
    expect(headings).toHaveLength(1);
    expect(headings[0].textContent.trim()).toBe('Panel Knock');
  });
});

describe('TC-TT-PRU-03-03 unauthenticated static page', () => {
  it('renders without login forms or interactive authentication controls', async () => {
    await TestBed.configureTestingModule({
      imports: [HomePageComponent],
    }).compileComponents();

    const fixture = TestBed.createComponent(HomePageComponent);
    fixture.detectChanges();

    const element = fixture.nativeElement as HTMLElement;
    expect(element.querySelectorAll('form, input[type="password"], a[href], button')).toHaveLength(
      0,
    );
    expect(element.textContent?.toLowerCase()).not.toContain('iniciar sesión');
  });
});
