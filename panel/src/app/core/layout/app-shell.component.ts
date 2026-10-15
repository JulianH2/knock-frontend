import { ChangeDetectionStrategy, Component } from '@angular/core';
import { RouterOutlet } from '@angular/router';

@Component({
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [RouterOutlet],
  selector: 'app-shell',
  standalone: true,
  styleUrl: './app-shell.component.scss',
  templateUrl: './app-shell.component.html',
})
export class AppShellComponent {}
