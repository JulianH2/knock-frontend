import { ChangeDetectionStrategy, Component } from '@angular/core';
import { AppShellComponent } from './core/layout/app-shell.component';

@Component({
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [AppShellComponent],
  selector: 'app-root',
  standalone: true,
  template: '<app-shell />',
})
export class App {}
