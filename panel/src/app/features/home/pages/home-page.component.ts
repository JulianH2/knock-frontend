import { ChangeDetectionStrategy, Component } from '@angular/core';
import { MatSidenavModule } from '@angular/material/sidenav';
import { StaticMenuComponent } from '../components/static-menu.component';

@Component({
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [MatSidenavModule, StaticMenuComponent],
  selector: 'app-home-page',
  standalone: true,
  styleUrl: './home-page.component.scss',
  templateUrl: './home-page.component.html',
})
export class HomePageComponent {}
