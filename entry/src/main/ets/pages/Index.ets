// 1. 定义基础坐标类
@Observed
class GamePoint {
  x: number = 0;
  y: number = 0;
  constructor(x: number, y: number) {
    this.x = x;
    this.y = y;
  }
}

// 2. 渲染数据类
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
  pIdx: number;
  finished: boolean = false;
  constructor(id: string, color: string, pIdx: number) {
    this.id = id;
    this.color = color;
    this.pIdx = pIdx;
  }
}

// --- 修正：规则弹窗组件 ---
@CustomDialog
struct RulesDialog {
  controller: CustomDialogController
  build() {
    Column() {
      Text('飞行棋游戏规则').fontSize(20).fontWeight(FontWeight.Bold).margin({ bottom: 15 })
      // 修正：ArkTS Scroll必须设置明确高度，且内部只能有一个根容器
      Scroll() {
        Column({ space: 10 }) {
          Text('1. 起飞：摇到 6 点即可将棋子移至起点格。').width('100%')
          Text('2. 连投：摇到 6 点或成功“踢人”后，获得额外机会。').width('100%')
          Text('3. 踢人：停留在对手所在普通格时，可将其踢回。').width('100%')
          Text('4. 安全区：起点格（紫色）免疫被踢，棋子重叠显示。').width('100%')
          Text('5. 终点：刚好走到最后一步完成，超出则回退。').width('100%')
        }.width('100%')
      }.height(150)

      Button('我知道了').margin({ top: 20 }).onClick(() => { this.controller.close() })
    }.padding(20).backgroundColor(Color.White).borderRadius(15)
  }
}

@Entry
@Component
struct Index {
  @State dice: number = 0
  @State currentPlayer: number = 0
  @State playerColors: string[] = ['#FFEC3D', '#1890FF', '#73D13D', '#FF4D4F']
  @State players: string[] = ['黄方', '蓝方', '绿方', '红方']
  @State canRoll: boolean = true
  @State allPlanes: Plane[] = []

  private pathGrid: GamePoint[] = []
  private finalPaths: GamePoint[][] = [[], [], [], []]
  private startIndices: number[] = [49, 10, 23, 36]

  dialogController: CustomDialogController = new CustomDialogController({
    builder: RulesDialog(),
    autoCancel: true,
    alignment: DialogAlignment.Center
  })

  aboutToAppear(): void {
    this.initGame()
  }

  initGame(): void {
    this.allPlanes = []
    for (let p = 0; p < 4; p++) {
      for (let i = 0; i < 4; i++) {
        this.allPlanes.push(new Plane(`P_${p}_${i}`, this.playerColors[p], p))
      }
    }
    this.generateMapData()
  }

  generateMapData(): void {
    let temp: GamePoint[] = []
    for (let y = 5; y >= 0; y--) temp.push(new GamePoint(6, y))
    temp.push(new GamePoint(7, 0))
    for (let y = 0; y <= 5; y++) temp.push(new GamePoint(8, y))
    for (let x = 9; x <= 14; x++) temp.push(new GamePoint(x, 6))
    temp.push(new GamePoint(14, 7))
    for (let x = 14; x >= 9; x--) temp.push(new GamePoint(x, 8))
    for (let y = 9; y <= 14; y++) temp.push(new GamePoint(8, y))
    temp.push(new GamePoint(7, 14))
    for (let y = 14; y >= 9; y--) temp.push(new GamePoint(6, y))
    for (let x = 5; x >= 0; x--) temp.push(new GamePoint(x, 8))
    temp.push(new GamePoint(0, 7))
    for (let x = 0; x <= 5; x++) temp.push(new GamePoint(x, 6))
    this.pathGrid = temp

    for(let i=1; i<=6; i++) this.finalPaths[0].push(new GamePoint(7, i))
    for(let i=13; i>=8; i--) this.finalPaths[1].push(new GamePoint(i, 7))
    for(let i=13; i>=8; i--) this.finalPaths[2].push(new GamePoint(7, i))
    for(let i=1; i<=6; i++) this.finalPaths[3].push(new GamePoint(i, 7))
  }

  rollDice(): void {
    if (!this.canRoll) return
    this.dice = Math.floor(Math.random() * 6) + 1
    this.canRoll = false
    let canMove = this.allPlanes.filter((p: Plane): boolean => p.pIdx === this.currentPlayer && !p.finished)
      .some((p: Plane): boolean => p.position !== -1 || this.dice === 6)
    if (!canMove) {
      setTimeout(() => { this.nextTurn() }, 800)
    }
  }

  movePlane(idx: number): void {
    if (this.canRoll || this.allPlanes[idx].pIdx !== this.currentPlayer) return
    let p = this.allPlanes[idx]
    if (p.finished) return

    let target: number = -1
    if (p.position === -1 && this.dice === 6) {
      target = this.startIndices[p.pIdx]
    } else if (p.position >= 0) {
      target = this.calculateTarget(p)
    }

    if (target !== -1) {
      p.position = target
      let kicked = this.checkKick(idx)
      this.allPlanes = [...this.allPlanes]
      if (kicked || this.dice === 6) {
        this.dice = 0
        this.canRoll = true
      } else {
        this.nextTurn()
      }
    }
  }

  calculateTarget(p: Plane): number {
    if (p.position < 52) {
      let turnPoint = this.startIndices[p.pIdx]
      let dist = (turnPoint - p.position + 52) % 52
      if (this.dice > dist && p.position !== turnPoint) {
        return 52 + (this.dice - dist - 1)
      }
      return (p.position + this.dice) % 52
    }
    let n = p.position + this.dice
    if (n > 57) return 57 - (n - 57)
    if (n === 57) p.finished = true
    return n
  }

  checkKick(moverIdx: number): boolean {
    let mover = this.allPlanes[moverIdx]
    let hit = false
    this.allPlanes.forEach((target: Plane) => {
      if (target.pIdx !== mover.pIdx && target.position === mover.position && target.position < 52) {
        if (this.startIndices.includes(target.position)) return
        target.position = -1
        hit = true
      }
    })
    return hit
  }

  // 显式声明返回类型 void
  nextTurn(): void {
    this.currentPlayer = (this.currentPlayer + 1) % 4
    this.dice = 0
    this.canRoll = true
  }

  getRenderData(idx: number): RenderData {
    let p = this.allPlanes[idx]
    if (p.position === -1) {
      const bases = [new GamePoint(1,1), new GamePoint(12,1), new GamePoint(12,12), new GamePoint(1,12)]
      let b = bases[p.pIdx]
      return new RenderData((b.x + (idx % 2)) * 20 + 10, (b.y + Math.floor((idx % 4) / 2)) * 20 + 10, 1)
    }
    let gp = p.position < 52 ? this.pathGrid[p.position] : this.finalPaths[p.pIdx][p.position - 52]
    let occupants = this.allPlanes.filter((item: Plane): boolean => item.position === p.position && item.position !== -1)
    if (occupants.length > 1) {
      let subIdx = occupants.indexOf(p)
      let off = 4
      let ox = (subIdx % 2 === 0) ? -off : off
      let oy = (subIdx < 2) ? -off : off
      return new RenderData(gp.x * 20 + 10 + ox, gp.y * 20 + 10 + oy, 0.7)
    }
    return new RenderData(gp.x * 20 + 10, gp.y * 20 + 10, 1)
  }

  build() {
    Column() {
      Row({ space: 10 }) {
        Button('游戏规则')
          .fontSize(14)
          .backgroundColor(Color.Gray)
          .height(40)
          .onClick(() => { this.dialogController.open() })

        // 修正：引用 players 确保被读取
        Text(`轮到：${this.players[this.currentPlayer]}`)
          .fontSize(18)
          .fontColor(this.playerColors[this.currentPlayer])
          .fontWeight(FontWeight.Bold)
      }.margin({ top: 15, bottom: 10 })

      // 修正：dice 必须转为 string
      Button(`掷骰子: ${this.dice === 0 ? '?' : this.dice.toString()}`)
        .width(160).height(50).onClick(() => this.rollDice()).margin(10)

      Stack() {
        // 修正：ForEach 必须显式使用参数，避免“never read”报错
        ForEach(this.pathGrid, (pos: GamePoint, index: number) => {
          Rect().width(19).height(19)
            .fill(this.startIndices.includes(index) ? '#E0B0FF' : Color.White)
            .stroke(Color.Black).strokeWidth(0.5)
            .position({ x: pos.x * 20, y: pos.y * 20 })
        }, (pos: GamePoint): string => JSON.stringify(pos))

        ForEach(this.finalPaths, (path: GamePoint[], pIdx: number) => {
          ForEach(path, (pos: GamePoint, idx: number) => {
            Rect().width(19).height(19).fill(this.playerColors[pIdx]).opacity(0.3).stroke(Color.Black).strokeWidth(0.5)
              .position({ x: pos.x * 20, y: pos.y * 20 })
          }, (pos: GamePoint): string => JSON.stringify(pos))
        }, (path: GamePoint[]): string => JSON.stringify(path))

        ForEach(this.allPlanes, (p: Plane, idx: number) => {
          Circle({ width: 14, height: 14 })
            .fill(p.color).stroke(Color.White).strokeWidth(1.5)
            .scale({ x: this.getRenderData(idx).scale, y: this.getRenderData(idx).scale })
            .position({ x: this.getRenderData(idx).x - 7, y: this.getRenderData(idx).y - 7 })
            .onClick(() => this.movePlane(idx))
            .animation({ duration: 300 })
        }, (p: Plane): string => p.id + p.position.toString())
      }
      .width(300).height(300).backgroundColor('#F5F5F5').border({ width: 2 })
    }.width('100%').height('100%')
  }
}