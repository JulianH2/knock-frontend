import { TestBed } from '@angular/core/testing';
import { StaticMenuComponent } from './static-menu.component';

describe('TC-TT-PRU-03-04 static menu labels', () => {
  it('shows the three static options without interactive controls', async () => {
    await TestBed.configureTestingModule({
      imports: [StaticMenuComponent],
    }).compileComponents();

    const fixture = TestBed.createComponent(StaticMenuComponent);
    fixture.detectChanges();

    const element = fixture.nativeElement as HTMLElement;
    expect(element.textContent).toContain('Verificaciones');
    expect(element.textContent).toContain('Reportes');
    expect(element.textContent).toContain('Métricas');
    expect(element.querySelector('a, button, [role="button"]')).toBeNull();
  });
});
