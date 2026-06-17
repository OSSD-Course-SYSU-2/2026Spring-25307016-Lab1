import mediaquery from '@ohos.mediaquery';
import promptAction from '@ohos.promptAction';

@Observed
class GamePoint {
  x: number = 0;
  y: number = 0;
  constructor(x: number, y: number) {
    this.x = x;
    this.y = y;
  }
}

class RenderData {
  x: number;
  y: number;
  scale: number;
  constructor(x: number, y: number, scale: number) {
    this.x = x;
    this.y = y;
    this.scale = scale;
  }
}

@Observed
class Plane {
  id: string;
  position: number = -1;
  color: string;
  pIdx: number; // 0:黄, 1:蓝, 2:绿, 3:红
  finished: boolean = false;
  constructor(id: string, color: string, pIdx: number) {
    this.id = id;
    this.color = color;
    this.pIdx = pIdx;
  }
}

class ChainResult {
  finalPos: number;
  tags: string[];
  constructor(finalPos: number, tags: string[]) {
    this.finalPos = finalPos;
    this.tags = tags;
  }
}

@CustomDialog
struct RulesDialog {
  controller: CustomDialogController
  build() {
    Column() {
      Text('游戏规则说明').fontSize(18).fontWeight(FontWeight.Bold).margin({ bottom: 12 })
      Scroll() {
        Column({ space: 10 }) {
          Text('【基础规则】').fontWeight(FontWeight.Bold).width('100%').fontSize(14)
          Text('1. 起飞：必须掷出 6 点，才能将棋子从基地移到起点格。').width('100%').fontSize(13)
          Text('2. 连投：掷出 6 点或者在路上成功吃掉对手的棋子，可以获得一次额外掷骰子的机会。').width('100%').fontSize(13)
          Text('3. 终点：棋子必须刚好走到最后一格才算胜利。如果骰子点数超出，棋子会往回倒退对应的步数。').width('100%').fontSize(13)
          Text('4. 碰撞：棋子停留在非安全格时，如果格子上有其他人的棋子，会把对方踢回基地。').width('100%').fontSize(13)

          Text('【Crazy模式新增规则】').fontWeight(FontWeight.Bold).fontColor('#FF4D4F').width('100%').fontSize(14)
          Text('1. 棋盘变色：普通棋格按黄、蓝、绿、红顺序循环排列。').width('100%').fontSize(13)
          Text('2. 同色跳跃：当棋子移动结束时，如果停在和自己颜色相同的普通棋格上，会触发跳跃，立即向前多走 4 格。注意：进入终点拐角前的那一格不触发跳跃。').width('100%').fontSize(13)
          Text('3. 跨海大飞行：棋盘内圈的 4 个拐角格为专属飞行起点（标有🛫）。当棋子刚好停在自己颜色的飞行起点时，会直接向对岸飞跃 12 格，降落在飞行终点（标有🛬）。').width('100%').fontSize(13)
          Text('4. 连锁效果：如果棋子先触发跳跃，跳跃后刚好落在自己的飞行起点上，会继续触发跨海大飞行。').width('100%').fontSize(13)
        }.width('100%')
      }.height(220)
      Button('我知道了').margin({ top: 15 }).onClick((): void => { this.controller.close() })
    }.padding(18).backgroundColor(Color.White).borderRadius(15)
  }
}

@Component
struct ModeSelectPage {
  @Link gameMode: string
  onSelect: (humanCount: number) => void = () => {}

  build() {
    Column({ space: 0 }) {
      Text('✈️ 飞行棋')
        .fontSize(42)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 60, bottom: 8 })

      Text('选择玩法和人数')
        .fontSize(16)
        .fontColor('#666666')
        .margin({ bottom: 30 })

      Row({ space: 10 }) {
        Button('经典模式')
          .height(40).layoutWeight(1)
          .fontSize(15).fontWeight(this.gameMode === 'classic' ? FontWeight.Bold : FontWeight.Normal)
          .backgroundColor(this.gameMode === 'classic' ? '#333333' : '#E0E0E0')
          .fontColor(this.gameMode === 'classic' ? Color.White : '#666666')
          .onClick(() => { this.gameMode = 'classic' })

        Button('Crazy模式')
          .height(40).layoutWeight(1)
          .fontSize(15).fontWeight(this.gameMode === 'crazy' ? FontWeight.Bold : FontWeight.Normal)
          .backgroundColor(this.gameMode === 'crazy' ? '#FF4D4F' : '#E0E0E0')
          .fontColor(this.gameMode === 'crazy' ? Color.White : '#666666')
          .onClick(() => { this.gameMode = 'crazy' })
      }
      .width('85%')
      .backgroundColor('#ECECEC')
      .borderRadius(12)
      .padding(4)
      .margin({ bottom: 35 })

      this.ModeCard('单人模式', '你 vs 3个电脑AI', '1', '#FF4D4F', 1)
      this.ModeCard('双人模式', '2人 vs 2个电脑AI', '2', '#1890FF', 2)
      this.ModeCard('三人模式', '3人 vs 1个电脑AI', '3', '#73D13D', 3)
      this.ModeCard('四人模式', '4人本地对战', '4', '#FFEC3D', 4)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FAFAFA')
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  ModeCard(title: string, subtitle: string, badge: string, color: string, humanCount: number) {
    Row() {
      Text(badge + '人')
        .width(52).height(52).borderRadius(26)
        .backgroundColor(color)
        .fontColor(humanCount === 4 ? '#333' : Color.White)
        .fontSize(16).fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Center).margin({ right: 16 })

      Column({ space: 4 }) {
        Text(title).fontSize(18).fontWeight(FontWeight.Bold).width('100%')
        Text(subtitle).fontSize(13).fontColor('#999999').width('100%')
      }.layoutWeight(1)

      Text('▶').fontSize(18).fontColor('#CCCCCC')
    }
    .width('85%')
    .padding({ left: 20, right: 20, top: 16, bottom: 16 })
    .backgroundColor(Color.White).borderRadius(16).margin({ bottom: 14 })
    .shadow({ radius: 8, color: '#1A000000', offsetX: 0, offsetY: 2 })
    .onClick((): void => { this.onSelect(humanCount) })
  }
}

@Entry
@Component
struct Index {
  @State pageState: string = 'menu'
  @State humanCount: number = 1
  @State gameMode: string = 'classic'

  @State dice: number = 0
  @State currentPlayer: number = 0
  @State playerColors: string[] = ['#FFEC3D', '#1890FF', '#73D13D', '#FF4D4F'] // 黄、蓝、绿、红
  @State mapCellColors: string[] = ['#FFFBE6', '#E6F7FF', '#F6FFED', '#FFF1F0'] // 对应浅色背景循环
  @State players: string[] = ['黄方', '蓝方', '绿方', '红方']
  @State canRoll: boolean = true
  @State allPlanes: Plane[] = []
  @State winnerMsg: string = ''
  @State aiThinking: boolean = false
  @State aiDiceDisplay: number = 0
  @State crazyEffectText: string = ''

  @State isLandscape: boolean = false
  private listener = mediaquery.matchMediaSync('(orientation: landscape) and (min-width: 600vp)')

  private pathGrid: GamePoint[] = []
  private finalPaths: GamePoint[][] = [[], [], [], []]
  private startIndices: number[] = [6, 19, 32, 45] // 各方起点

  private flightStarts: number[] = [13, 26, 39, 0]
  private flightEnds: number[] = [25, 38, 51, 12]

  private AI_ROLL_DELAY: number = 800
  private AI_MOVE_DELAY: number = 600
  private timerId: number = -1

  private CELL_SIZE: number = 24

  dialogController: CustomDialogController = new CustomDialogController({
    builder: RulesDialog(),
    autoCancel: true,
    alignment: DialogAlignment.Center
  })

  onOrientationChange = (mediaQueryResult: mediaquery.MediaQueryResult) => {
    this.isLandscape = mediaQueryResult.matches
  }

  aboutToAppear(): void {
    this.listener.on('change', this.onOrientationChange)
    this.isLandscape = this.listener.matches
  }

  aboutToDisappear(): void {
    this.listener.off('change', this.onOrientationChange)
    if (this.timerId !== -1) {
      clearTimeout(this.timerId)
    }
  }

  isAI(playerIdx: number): boolean {
    return playerIdx >= this.humanCount
  }

  initGame(hCount: number): void {
    if (this.timerId !== -1) {
      clearTimeout(this.timerId)
    }
    this.humanCount = hCount
    this.pageState = 'game'
    this.allPlanes = []
    this.winnerMsg = ''
    this.currentPlayer = 0
    this.dice = 0
    this.aiDiceDisplay = 0
    this.canRoll = true
    this.aiThinking = false
    this.crazyEffectText = ''
    for (let p: number = 0; p < 4; p++) {
      for (let i: number = 0; i < 4; i++) {
        this.allPlanes.push(new Plane(`P_${p}_${i}`, this.playerColors[p], p))
      }
    }
    this.generateMapData()
    if (this.isAI(0)) {
      this.scheduleAIRoll()
    }
  }

  generateMapData(): void {
    this.pathGrid = []
    this.finalPaths = [[], [], [], []]
    let temp: GamePoint[] = []
    for (let y: number = 5; y >= 0; y--) temp.push(new GamePoint(6, y))
    temp.push(new GamePoint(7, 0))
    for (let y: number = 0; y <= 5; y++) temp.push(new GamePoint(8, y))
    for (let x: number = 9; x <= 14; x++) temp.push(new GamePoint(x, 6))
    temp.push(new GamePoint(14, 7))
    for (let x: number = 14; x >= 9; x--) temp.push(new GamePoint(x, 8))
    for (let y: number = 9; y <= 14; y++) temp.push(new GamePoint(8, y))
    temp.push(new GamePoint(7, 14))
    for (let y: number = 14; y >= 9; y--) temp.push(new GamePoint(6, y))
    for (let x: number = 5; x >= 0; x--) temp.push(new GamePoint(x, 8))
    temp.push(new GamePoint(0, 7))
    for (let x: number = 0; x <= 5; x++) temp.push(new GamePoint(x, 6))
    this.pathGrid = temp

    this.finalPaths = [[], [], [], []]
    for (let i: number = 1; i <= 6; i++) this.finalPaths[0].push(new GamePoint(7, i))
    for (let i: number = 13; i >= 8; i--) this.finalPaths[1].push(new GamePoint(i, 7))
    for (let i: number = 13; i >= 8; i--) this.finalPaths[2].push(new GamePoint(7, i))
    for (let i: number = 1; i <= 6; i++) this.finalPaths[3].push(new GamePoint(i, 7))
  }

  rollDice(): void {
    if (!this.canRoll || this.winnerMsg !== '') return
    if (this.isAI(this.currentPlayer)) return
    this.doRoll()
  }

  doRoll(): void {
    this.crazyEffectText = '' // 🌟 摇骰子时强制清空上一回合留下的文字
    let rolled: number = Math.floor(Math.random() * 6) + 1
    this.dice = rolled
    if (this.isAI(this.currentPlayer)) {
      this.aiDiceDisplay = rolled
      this.aiThinking = false
    }
    this.canRoll = false

    let canMove: boolean = this.allPlanes
      .filter((p: Plane): boolean => p.pIdx === this.currentPlayer && !p.finished)
      .some((p: Plane): boolean => p.position !== -1 || this.dice === 6)

    if (!canMove) {
      this.timerId = setTimeout((): void => { this.nextTurn() }, 900)
    } else if (this.isAI(this.currentPlayer)) {
      this.timerId = setTimeout((): void => { this.aiChooseAndMove() }, this.AI_MOVE_DELAY)
    }
  }

  scheduleAIRoll(): void {
    this.aiThinking = true
    this.aiDiceDisplay = 0
    this.canRoll = false
    this.timerId = setTimeout((): void => {
      if (this.winnerMsg !== '') return
      this.doRoll()
    }, this.AI_ROLL_DELAY)
  }

  aiChooseAndMove(): void {
    let myPlanes: number[] = this.allPlanes
      .map((_p: Plane, i: number): number => i)
      .filter((i: number): boolean => {
        let p: Plane = this.allPlanes[i];
        return p.pIdx === this.currentPlayer && !p.finished && (p.position !== -1 || this.dice === 6);
      });

    if (myPlanes.length === 0) {
      this.nextTurn();
      return;
    }

    let chosenIdx: number = this.aiBestPlane(myPlanes);
    this.movePlane(chosenIdx);
  }

  aiBestPlane(idxList: number[]): number {
    let bestIdx: number = idxList[0];
    let maxScore: number = -99999;

    for (let i of idxList) {
      let score = this.evaluateMove(i);
      if (score > maxScore) {
        maxScore = score;
        bestIdx = i;
      }
    }
    return bestIdx;
  }

  // 🌟 核心修复：重构大飞行与普通跳跃的先后秩序与条件阻断
  processCrazyChain(startPos: number, pIdx: number): ChainResult {
    let current: number = startPos;
    let tags: string[] = [];

    if (current < 52 && current >= 0) {
      // 1. 如果刚好精准踩中自己的海三大飞行起点，立刻直接飞越
      if (current === this.flightStarts[pIdx]) {
        current = this.flightEnds[pIdx];
        tags.push('🚀 跨海大飞行！');
      }
      // 2. 如果没踩中飞行起点，再判断是不是同色格，触发跳跃
      else {
        let turnPreClickIdx = (this.startIndices[pIdx] - 1 + 52) % 52;
        let cellColorIdx = this.getLogicColorIndex(current);
        if (cellColorIdx === pIdx && current !== turnPreClickIdx) {
          current = (current + 4) % 52;
          tags.push('✈️ 跳跃！');

          // 3. 跳跃4格之后，如果又恰好落到了飞行起点上，触发【连带连锁大飞行】
          if (current === this.flightStarts[pIdx]) {
            current = this.flightEnds[pIdx];
            tags.push('🚀 跨海大飞行！');
          }
        }
      }
    }
    return new ChainResult(current, tags);
  }

  evaluateMove(planeIdx: number): number {
    let p: Plane = this.allPlanes[planeIdx];
    let score: number = 0;
    let isSprintMode = this.allPlanes.filter((pl: Plane) => pl.pIdx === this.currentPlayer && pl.finished).length >= 2;

    let currentPos = p.position;
    let simulatedTarget = -1;

    if (currentPos === -1 && this.dice === 6) {
      simulatedTarget = this.startIndices[p.pIdx];
    } else if (currentPos >= 0) {
      simulatedTarget = this.calculateTargetVirtual(p);
    }

    if (simulatedTarget === -1) return -9999;

    let hasFlown = false;
    if (this.gameMode === 'crazy' && simulatedTarget < 52 && simulatedTarget >= 0) {
      let chain: ChainResult = this.processCrazyChain(simulatedTarget, p.pIdx);
      simulatedTarget = chain.finalPos;
      if (chain.tags.includes('✈️ 跳跃！')) { score += 30; }
      if (chain.tags.includes('🚀 跨海大飞行！')) { score += 50; hasFlown = true; }
    }

    if (currentPos >= 52) {
      let nextPosRaw = currentPos + this.dice;
      if (nextPosRaw > 57) {
        score -= 250;
      }
    }

    if (simulatedTarget === 57) {
      score += this.gameMode === 'crazy' ? 200 : (isSprintMode ? 600 : 300);
    }

    if (simulatedTarget >= 52 && simulatedTarget < 57 && currentPos < 52) {
      score += this.gameMode === 'crazy' ? 40 : (isSprintMode ? 160 : 80);
    }

    if (simulatedTarget >= 52 && simulatedTarget < 57 && currentPos >= 52) {
      score += 20;
    }

    if (simulatedTarget < 52) {
      let canKickEnemy = this.allPlanes.some((targetPlane: Plane): boolean =>
      targetPlane.pIdx !== this.currentPlayer &&
        targetPlane.position === simulatedTarget &&
        !targetPlane.finished &&
        !this.startIndices.includes(simulatedTarget)
      );
      if (canKickEnemy) {
        score += this.gameMode === 'crazy' ? 80 : 150;
        if (this.gameMode === 'crazy' && hasFlown) {
          score += 120;
        }
      }
    }

    if (currentPos < 52 && currentPos >= 0) {
      score += currentPos * 2;
      if (currentPos > 40) {
        score += 50;
      }
    }

    if (simulatedTarget < 52 && simulatedTarget >= 0 && !this.startIndices.includes(simulatedTarget)) {
      let dangerCount = this.getDangerCount(simulatedTarget);
      let penaltyPerThreat = isSprintMode ? 40 : 20;
      let heavyThreatPenalty = isSprintMode ? 80 : 40;

      score -= dangerCount * penaltyPerThreat;
      if (dangerCount >= 2) {
        score -= heavyThreatPenalty;
      }
    }

    if (this.startIndices.includes(simulatedTarget)) {
      score += 60;
    }

    if (currentPos === -1 && this.dice === 6) {
      let activePlanesCount = this.allPlanes.filter((pl: Plane) => pl.pIdx === this.currentPlayer && pl.position !== -1 && !pl.finished).length;
      if (activePlanesCount === 1) {
        score += 100;
      } else {
        score += 70;
      }
    }

    return score;
  }

  getDangerCount(targetPos: number): number {
    let count = 0;
    this.allPlanes.forEach((enemy: Plane) => {
      if (enemy.pIdx === this.currentPlayer || enemy.position === -1 || enemy.finished) return;

      if (enemy.position < 52) {
        let distance = (targetPos - enemy.position + 52) % 52;
        if (distance >= 1 && distance <= 6) {
          count++;
        }
      }
    });
    return count;
  }

  calculateTargetVirtual(p: Plane): number {
    let rolled: number = this.dice;
    if (p.position === -1) return -1;
    if (p.position < 52) {
      let preTurnIdx: number = (this.startIndices[p.pIdx] - 1 + 52) % 52;
      let distToTurn: number = (preTurnIdx - p.position + 52) % 52;
      if (rolled <= distToTurn) { return (p.position + rolled) % 52; }
      let into: number = rolled - distToTurn;
      return 52 + (into - 1);
    }
    let n: number = p.position + rolled;
    if (n > 57) { return 57 - (n - 57); }
    return n;
  }

  movePlane(idx: number): void {
    if (this.allPlanes[idx].pIdx !== this.currentPlayer) return
    let p: Plane = this.allPlanes[idx]
    if (p.finished) return

    let target: number = -1;
    if (p.position === -1 && this.dice === 6) {
      target = this.startIndices[p.pIdx];
    } else if (p.position >= 0) {
      target = this.calculateTargetVirtual(p);
    }

    if (target !== -1) {
      p.position = target;
      this.crazyEffectText = '';

      if (this.gameMode === 'crazy' && p.position < 52 && p.position >= 0) {
        let chain: ChainResult = this.processCrazyChain(p.position, p.pIdx);
        p.position = chain.finalPos;
        if (chain.tags.length > 0) {
          this.crazyEffectText = chain.tags.join(' ➔ ');
        }
      }

      if (p.position === 57) {
        p.finished = true;
        promptAction.showToast({
          message: `🎉 ${this.players[this.currentPlayer]} 有一枚棋子成功到达终点！`,
          duration: 2000
        });
      }

      let kicked: boolean = this.checkKick(idx)
      if (kicked && this.gameMode === 'crazy') {
        this.crazyEffectText += (this.crazyEffectText === '' ? '' : ' ➔ ') + '💥 踢飞敌机！';
      }
      this.allPlanes = [...this.allPlanes]

      let allDone: boolean = this.allPlanes
        .filter((pl: Plane): boolean => pl.pIdx === this.currentPlayer)
        .every((pl: Plane): boolean => pl.finished)
      if (allDone) {
        this.winnerMsg = `${this.players[this.currentPlayer]}`;
        this.aiThinking = false;
        return;
      }

      if (kicked || this.dice === 6) {
        this.dice = 0
        this.canRoll = true
        this.aiThinking = false
        if (this.isAI(this.currentPlayer)) {
          this.scheduleAIRoll()
        }
      } else {
        this.nextTurn()
      }
    }
  }

  checkKick(moverIdx: number): boolean {
    let mover: Plane = this.allPlanes[moverIdx]
    let hit: boolean = false
    this.allPlanes.forEach((target: Plane): void => {
      if (target.pIdx !== mover.pIdx && target.position === mover.position && target.position < 52) {
        if (this.startIndices.includes(target.position)) return
        target.position = -1
        hit = true
      }
    })
    return hit
  }

  // 🌟 核心修复：在此处立刻斩断清空上一回合留下的红字效果
  nextTurn(): void {
    this.crazyEffectText = '' // 👈 切换阵营瞬间，旧的“跳跃！”等字样立刻蒸发消失
    this.currentPlayer = (this.currentPlayer + 1) % 4
    this.dice = 0
    this.aiDiceDisplay = 0
    this.canRoll = true
    this.aiThinking = false
    if (this.winnerMsg !== '') return
    if (this.isAI(this.currentPlayer)) {
      this.scheduleAIRoll()
    }
  }

  getRenderData(idx: number): RenderData {
    let p: Plane = this.allPlanes[idx]
    let size = this.CELL_SIZE
    let half = size / 2

    if (p.position === -1) {
      const bases: GamePoint[] = [
        new GamePoint(1, 1), new GamePoint(12, 1),
        new GamePoint(12, 12), new GamePoint(1, 12)
      ]
      let b: GamePoint = bases[p.pIdx]
      let bx = (b.x + (idx % 2)) * size + half
      let by = (b.y + Math.floor((idx % 4) / 2)) * size + half
      return new RenderData(bx, by, 1.0)
    }

    let gp: GamePoint = p.position < 52
      ? this.pathGrid[p.position]
      : this.finalPaths[p.pIdx][p.position - 52]

    let occupants: Plane[] = []
    if (p.position === 57) {
      occupants = this.allPlanes.filter((item: Plane): boolean => item.position === 57 && item.pIdx === p.pIdx)
    } else {
      occupants = this.allPlanes.filter((item: Plane): boolean => item.position === p.position && !item.finished)
    }

    if (occupants.length > 1) {
      let subIdx: number = occupants.indexOf(p)
      if (subIdx !== -1) {
        let off: number = size * 0.23
        let ox = 0
        let oy = 0
        if (subIdx === 0) { ox = -off; oy = -off; }
        else if (subIdx === 1) { ox = off; oy = -off; }
        else if (subIdx === 2) { ox = -off; oy = off; }
        else if (subIdx === 3) { ox = off; oy = off; }

        return new RenderData(gp.x * size + half + ox, gp.y * size + half + oy, 0.65)
      }
    }

    return new RenderData(gp.x * size + half, gp.y * size + half, 1.0)
  }

  getLogicColorIndex(index: number): number {
    return (index + 3) % 4;
  }

  getCellFillColor(index: number): string {
    if (this.startIndices.includes(index)) {
      return '#E0B0FF';
    }
    if (this.gameMode === 'crazy') {
      return this.mapCellColors[this.getLogicColorIndex(index)];
    }
    return Color.White.toString();
  }

  @Builder
  PlayerTags() {
    Row({ space: 6 }) {
      ForEach(this.players, (name: string, i: number) => {
        Column({ space: 2 }) {
          Text(name)
            .fontSize(12)
            .fontColor(this.playerColors[i])
            .fontWeight(i === this.currentPlayer ? FontWeight.Bold : FontWeight.Normal)
          Text(this.isAI(i) ? '🤖' : '👤').fontSize(11)
        }
        .padding({ left: 10, right: 10, top: 5, bottom: 5 })
        .borderRadius(8)
        .backgroundColor(i === this.currentPlayer ? '#F0F0F0' : 'transparent')
        .border({ width: i === this.currentPlayer ? 1.5 : 0, color: this.playerColors[i] })
      }, (name: string): string => name)
    }.width('100%').justifyContent(FlexAlign.Center)
  }

  build() {
    Stack() {
      if (this.pageState === 'menu') {
        ModeSelectPage({ gameMode: $gameMode, onSelect: (hc: number): void => { this.initGame(hc) } })
      } else {
        Flex({
          direction: this.isLandscape ? FlexDirection.Row : FlexDirection.Column,
          justifyContent: FlexAlign.Center,
          alignItems: ItemAlign.Center
        }) {
          // ------- 控制面板面板 -------
          Column({ space: 12 }) {
            Row({ space: 10 }) {
              Button('< 返回')
                .fontSize(13).backgroundColor('#888888').height(36)
                .onClick((): void => { this.pageState = 'menu'; this.aiThinking = false })
              Button('游戏规则')
                .fontSize(13).backgroundColor(Color.Gray).height(36)
                .onClick((): void => { this.dialogController.open() })
            }.margin({ top: 10 })

            this.PlayerTags()

            if (this.winnerMsg === '') {
              Text(`轮到：${this.players[this.currentPlayer]}${this.isAI(this.currentPlayer) ? ' 🤖' : ''}`)
                .fontSize(18)
                .fontColor(this.playerColors[this.currentPlayer])
                .fontWeight(FontWeight.Bold)
            }

            Row() {
              if (this.winnerMsg === '') {
                if (this.isAI(this.currentPlayer)) {
                  if (this.aiThinking) {
                    Text('🤖 思考中…').fontSize(16).fontColor('#999999')
                  } else {
                    Text(`🤖 掷出了：${this.aiDiceDisplay}`)
                      .fontSize(18).fontColor(this.playerColors[this.currentPlayer]).fontWeight(FontWeight.Bold)
                  }
                } else {
                  Button(`🎲 掷骰子${this.dice !== 0 ? '：' + this.dice.toString() : ''}`)
                    .width(180).height(46).fontSize(16)
                    .enabled(this.canRoll)
                    .opacity(this.canRoll ? 1 : 0.5)
                    .onClick((): void => { this.rollDice() })
                }
              }
            }
            .width('100%')
            .height(55)
            .justifyContent(FlexAlign.Center)
            .alignItems(VerticalAlign.Center)

            if (this.gameMode === 'crazy' && this.crazyEffectText !== '') {
              Text(this.crazyEffectText)
                .fontSize(14)
                .fontColor('#FF4D4F')
                .fontWeight(FontWeight.Bold)
                .backgroundColor('#FFF1F0')
                .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                .borderRadius(6)
                .border({ width: 1, color: '#FFA39E' })
            }
          }
          .padding(20)
          .width(this.isLandscape ? '30%' : '100%')
          .constraintSize({ maxHeight: this.isLandscape ? 400 : '100%' })
          .alignItems(HorizontalAlign.Center)

          // ------- 棋盘区 -------
          Column() {
            Stack() {
              ForEach(this.pathGrid, (pos: GamePoint, index: number) => {
                Stack() {
                  Rect().width(this.CELL_SIZE - 1).height(this.CELL_SIZE - 1)
                    .fill(this.getCellFillColor(index))
                    .stroke(Color.Black).strokeWidth(0.5)

                  if (this.gameMode === 'crazy') {
                    if (this.flightStarts.includes(index)) {
                      Text('🛫')
                        .fontSize(10)
                        .fontColor(this.playerColors[this.flightStarts.indexOf(index)])
                        .fontWeight(FontWeight.Bold)
                    } else if (this.flightEnds.includes(index)) {
                      Text('🛬')
                        .fontSize(10)
                        .fontColor(this.playerColors[this.flightEnds.indexOf(index)])
                        .fontWeight(FontWeight.Bold)
                    }
                  }
                }.position({ x: pos.x * this.CELL_SIZE, y: pos.y * this.CELL_SIZE })
              }, (pos: GamePoint): string => JSON.stringify(pos))

              ForEach(this.finalPaths, (path: GamePoint[], pIdx: number) => {
                ForEach(path, (pos: GamePoint): void => {
                  Rect().width(this.CELL_SIZE - 1).height(this.CELL_SIZE - 1)
                    .fill(this.playerColors[pIdx]).opacity(0.3)
                    .stroke(Color.Black).strokeWidth(0.5)
                    .position({ x: pos.x * this.CELL_SIZE, y: pos.y * this.CELL_SIZE })
                }, (pos: GamePoint): string => JSON.stringify(pos))
              }, (path: GamePoint[]): string => JSON.stringify(path))

              ForEach(this.allPlanes, (p: Plane, idx: number) => {
                Circle({ width: this.CELL_SIZE * 0.65, height: this.CELL_SIZE * 0.65 })
                  .fill(p.color).stroke(Color.White).strokeWidth(1.5)
                  .scale({ x: this.getRenderData(idx).scale, y: this.getRenderData(idx).scale })
                  .position({ x: this.getRenderData(idx).x - (this.CELL_SIZE * 0.65)/2, y: this.getRenderData(idx).y - (this.CELL_SIZE * 0.65)/2 })
                  .onClick((): void => {
                    if (!this.isAI(this.currentPlayer)) { this.movePlane(idx) }
                  })
                  .animation({ duration: 350, curve: Curve.FastOutSlowIn })
              }, (p: Plane): string => p.id + p.position.toString())
            }
            .width(15 * this.CELL_SIZE).height(15 * this.CELL_SIZE).backgroundColor('#F5F5F5').border({ width: 2 })
          }
          .layoutWeight(this.isLandscape ? 0 : 1)
          .width(this.isLandscape ? '55%' : '100%')
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)

        }
        .width(this.isLandscape ? '90%' : '100%')
        .height('100%')
        .backgroundColor('#FAFAFA')
        .margin({ left: 'auto', right: 'auto' })
      }

      if (this.winnerMsg !== '') {
        Column({ space: 25 }) {
          Text('🏆 游戏结束 🏆')
            .fontSize(40)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFD700')
            .shadow({ radius: 15, color: '#80000000' })

          Text(`恭喜 【${this.winnerMsg}】 获得本局胜利！`)
            .fontSize(22)
            .fontColor(Color.White)
            .fontWeight(FontWeight.Medium)
            .margin({ bottom: 10 })

          Button('再来一局')
            .width(180).height(50).fontSize(18).fontWeight(FontWeight.Bold)
            .backgroundColor('#1890FF').fontColor(Color.White)
            .borderRadius(25)
            .onClick((): void => { this.initGame(this.humanCount) })

          Button('返回主菜单')
            .width(180).height(50).fontSize(16)
            .backgroundColor('#444444').fontColor('#CCCCCC')
            .borderRadius(25)
            .onClick((): void => { this.pageState = 'menu'; this.winnerMsg = '' })
        }
        .width('100%').height('100%')
        .backgroundColor('#E6000000')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      }
    }
  }
}