import { ChangeDetectionStrategy, Component } from '@angular/core';
import { MatListModule } from '@angular/material/list';

@Component({
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [MatListModule],
  selector: 'app-static-menu',
  standalone: true,
  styleUrl: './static-menu.component.scss',
  templateUrl: './static-menu.component.html',
})
export class StaticMenuComponent {}
