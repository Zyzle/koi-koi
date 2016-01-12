import {Component, Input} from 'angular2/core';

import {Card} from '../../cards';

import {GameCard} from './gamecard';

@Component({
  directives: [GameCard],
  selector: 'game-player',
  template: `
    <div [attr.id]="playerName" class="player">
      <game-card [card]="card" [size]="cardSize" *ngFor="#card of cards" [faceUp]="player"
        class="container" (cardSelect)="cardClick($event)"></game-card>
    </div>
  `,
  styles: [`
    .player {
      display: flex;
      margin: 20px
    }

    .container {
      flex: 1 0 0;
    }

    .container:last-child {
      flex: 0 0 auto;
    }
  `],

})
export class GamePlayer {
  @Input()
  playerName:string;

  @Input()
  cards:Card[] = [];

  @Input()
  player:boolean;

  cardSize = {height: '101px', width: '64px'};

  cardClick(card:Card) {
    console.log(card);
  }
}
