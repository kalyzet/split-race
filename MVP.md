# MVP — SPLIT-RACE

## 1. Project Overview

Split-Race adalah game balapan 2D bergaya arcade dengan perspektif top-down. Pemain mengendalikan mobil dalam lintasan balap yang memiliki berbagai macam tikungan dan kembali ke garis start setelah menyelesaikan satu putaran.

Game memiliki dua mode utama:

- Single Player — 1 pemain melawan 6 mobil CPU.
- Local Multiplayer — 2 pemain dalam satu keyboard melawan 5 mobil CPU.

Fokus utama game adalah balapan sederhana, cepat, mudah dimainkan, dan menyenangkan ketika dimainkan bersama secara lokal.

Tidak ada online multiplayer dalam MVP.

---

## 2. Core Concept

Pemain mengendarai mobil pada lintasan tertutup dan harus menyelesaikan sejumlah lap terlebih dahulu untuk memenangkan balapan.

Satu race terdiri dari:

- 7 mobil total.
- Maksimal 2 mobil dikendalikan pemain.
- Sisanya dikendalikan CPU.
- 2 atau 3 lap.
- Collision antar mobil aktif.
- Setiap mobil memiliki posisi/ranking selama balapan.
- Race berakhir ketika seluruh kondisi finish terpenuhi.
- Setelah race selesai, game menampilkan hasil dan statistik.

Core gameplay loop:

```text
Home
  ↓
Select Mode
  ↓
Race Setup
  ↓
Race
  ↓
Finish
  ↓
Results
  ↓
Home / Play Again
```

---

# 3. MVP Goals

MVP dianggap berhasil apabila pemain dapat:

1. Membuka game.
2. Melihat Home Screen.
3. Memilih Single Player atau Multiplayer.
4. Memilih jumlah lap.
5. Memulai race.
6. Mengendalikan mobil.
7. Melakukan pengereman.
8. Menggunakan turbo.
9. Bertabrakan dengan mobil lain.
10. Melihat 7 mobil berada dalam race.
11. Melihat progress lap.
12. Menyelesaikan race.
13. Melihat ranking akhir.
14. Melihat waktu balapan.
15. Mengulang race.
16. Kembali ke Home Screen.

Untuk Multiplayer:

17. Player 1 dan Player 2 dapat bermain bersamaan menggunakan keyboard yang sama.
18. Kedua player berada dalam dunia/game race yang sama.
19. Kamera kedua player dapat mengikuti mobil masing-masing menggunakan split-screen.

---

# 4. Game Modes

## 4.1 Single Player

Komposisi:

```text
Player 1
+
6 CPU
=
7 Cars
```

Player menggunakan kontrol Player 1.

CPU dikendalikan oleh AI sederhana yang mengikuti racing line/path pada track.

---

## 4.2 Local Multiplayer

Komposisi:

```text
Player 1
Player 2
+
5 CPU
=
7 Cars
```

Kedua player menggunakan keyboard yang sama.

Player 1:

```text
W = Turn Upwards
A = Turn Left
S = Turn Downwards
D = Turn Right
Q = Brake
E = Turbo
```

Player 2:

```text
I = Turn Upwards
J = Turn Left
K = Turn Downwards
L = Turn Right
O = Brake
U = Turbo
```

Tidak diperlukan controller/gamepad dalam MVP.

---

# 5. Controls

## Player 1

| Action         | Key |
| -------------- | --- |
| Turn Upwards   | W   |
| Turn Left      | A   |
| Turn Downwards | S   |
| Turn Right     | D   |
| Brake          | Q   |
| Turbo          | E   |

## Player 2

| Action         | Key |
| -------------- | --- |
| Turn Upwards   | I   |
| Turn Left      | J   |
| Turn Downwards | K   |
| Turn Right     | L   |
| Brake          | O   |
| Turbo          | U   |

## General Controls

Tombol tambahan dapat digunakan untuk UI apabila diperlukan, tetapi tidak menjadi bagian dari gameplay utama.

Contoh:

```text
ESC = Pause / Back
ENTER = Confirm
```

Implementasi input harus menggunakan Godot Input Map, bukan hard-code pemeriksaan keyboard di setiap script.

---

# 6. Race Rules

## 6.1 Number of Cars

Setiap race selalu memiliki:

```text
7 Cars
```

Single Player:

```text
1 Player + 6 CPU
```

Multiplayer:

```text
2 Player + 5 CPU
```

---

## 6.2 Number of Laps

Pemain dapat memilih:

```text
2 Laps
3 Laps
```

Default:

```text
2 Laps
```

Jumlah lap harus dapat digunakan oleh Race Manager sehingga track tidak perlu memiliki logic khusus untuk jumlah lap tertentu.

---

## 6.3 Race Start

Sebelum race dimulai, semua mobil ditempatkan pada starting grid.

Contoh:

```text
      START LINE
────────────────────

🚗  🚙
🚕  🚓
🚗  🚙
🚕
```

Race menggunakan countdown:

```text
3
2
1
GO!
```

Mobil tidak boleh bergerak sebelum race dimulai.

---

## 6.4 Finish Condition

Sebuah mobil menyelesaikan race setelah:

```text
Semua checkpoint pada lap terakhir
+
melewati garis finish
```

Mobil yang finish tetap berada di track atau masuk ke kondisi finished dan tidak lagi dapat bergerak atau berkompetisi secara normal.

Ranking ditentukan berdasarkan urutan mobil menyelesaikan race.

Race dapat berakhir setelah seluruh mobil selesai atau setelah seluruh player selesai.

Untuk MVP, Race Manager menggunakan kondisi yang konsisten untuk seluruh race dan tidak bergantung pada siapa yang finish terlebih dahulu.

---

# 7. Track

## 7.1 Track Type

Track berbentuk closed circuit.

Contoh konsep:

```text
             ┌──────────────┐
             │              │
 START ──────┘              │
 │                          │
 │       ┌──────────┐       │
 │       │          │       │
 │       └────┐     │       │
 │            │     │       │
 └────────────┴─────┴───────┘
```

Track harus kembali ke starting line sehingga satu putaran dapat dihitung.

---

## 7.2 Track Characteristics

Track MVP harus memiliki variasi arah dan bentuk.

Minimal memiliki:

- Straight section.
- Gentle turn.
- Sharp turn.
- S-turn atau kombinasi tikungan.
- Area sempit.
- Area relatif lebar.

Tujuannya agar race tidak hanya berupa lingkaran sederhana.

---

## 7.3 Checkpoints

Track menggunakan checkpoint untuk menentukan progress mobil.

Contoh:

```text
START
 ↓
Checkpoint 1
 ↓
Checkpoint 2
 ↓
Checkpoint 3
 ↓
Checkpoint 4
 ↓
START / FINISH
```

Mobil harus melewati checkpoint secara berurutan.

Checkpoint digunakan untuk:

- Validasi lap.
- Menentukan progress race.
- Menentukan ranking.
- Mencegah shortcut yang tidak valid.

---

# 8. Car System

Setiap mobil memiliki sistem movement yang sama secara dasar.

Parameter utama:

```text
speed
max_speed
acceleration
brake_force
steering
friction
turbo
```

Nilai parameter dapat berbeda antar mobil apabila diperlukan.

Namun pada MVP, semua mobil boleh menggunakan statistik dasar yang sama agar balancing lebih mudah.

---

## 8.1 Acceleration

Ketika accelerate aktif:

```text
speed += acceleration
```

Speed tidak boleh melebihi:

```text
max_speed
```

---

## 8.2 Braking

Ketika tombol brake ditekan:

```text
speed -= brake_force
```

Mobil tidak boleh memiliki speed negatif yang tidak diperlukan oleh sistem movement.

---

## 8.3 Steering

Mobil dapat berbelok ke kiri atau kanan berdasarkan input steering.

Steering harus mempertimbangkan kecepatan mobil.

Secara gameplay:

```text
Low Speed
→ easier steering

High Speed
→ harder / less responsive steering
```

Tujuannya menghasilkan kontrol arcade, bukan simulasi kendaraan realistis.

---

## 8.4 Friction

Ketika acceleration tidak digunakan, mobil secara perlahan kehilangan speed.

Contoh:

```text
No acceleration
        ↓
Friction
        ↓
Speed decreases
```

Mobil tidak langsung berhenti.

---

# 9. Turbo

Turbo adalah fitur boost yang memberikan peningkatan kecepatan sementara.

Player 1:

```text
E
```

Player 2:

```text
U
```

MVP turbo menggunakan resource/meter sederhana.

Contoh:

```text
TURBO
███████░░░
```

Ketika turbo digunakan:

```text
Turbo active
↓
temporary speed boost
↓
turbo meter decreases
```

Turbo tidak boleh membuat mobil bergerak tanpa batas.

Detail balancing seperti:

- kapasitas meter,
- recharge,
- boost multiplier,
- duration,

dapat ditentukan ketika implementasi gameplay dimulai.

---

# 10. Collision

Collision antar mobil aktif.

Mobil dapat:

- Menabrak mobil lain.
- Terdorong ketika terjadi tabrakan.
- Kehilangan racing line akibat tabrakan.

Collision tidak menggunakan damage system dalam MVP.

Tidak ada:

- HP.
- Vehicle destruction.
- Repair.
- Explosion.

Fokus collision adalah gameplay dan chaos balapan.

---

# 11. AI / CPU

CPU menggunakan AI sederhana.

AI tidak membutuhkan machine learning atau sistem pathfinding kompleks.

Setiap track memiliki racing path/waypoints.

Contoh:

```text
●──●──●──●──●──●──●
        Track Path
```

CPU mencoba:

1. Menentukan waypoint berikutnya.
2. Mengarahkan mobil menuju waypoint.
3. Mengatur acceleration.
4. Mengurangi speed ketika memasuki tikungan.
5. Melanjutkan ke waypoint berikutnya.

CPU harus tetap menggunakan sistem mobil yang sama secara umum agar behavior player dan CPU tidak terlalu berbeda.

---

## 11.1 CPU Difficulty

MVP minimal menyediakan:

```text
Easy
Normal
Hard
```

Perbedaan difficulty dapat dibuat melalui parameter sederhana seperti:

- Maximum speed.
- Acceleration.
- Steering accuracy.
- Braking behavior.
- Mistake probability.

Tidak perlu AI architecture berbeda untuk setiap difficulty.

---

# 12. Race Ranking

Ranking harus dapat dihitung secara real-time.

Prioritas progress:

```text
Completed Laps
      ↓
Checkpoint Progress
      ↓
Distance to Next Checkpoint
```

Contoh:

```text
Player 1
Lap 2
Checkpoint 5
Distance = 20m

Player 2
Lap 2
Checkpoint 5
Distance = 35m
```

Player 1 berada di depan Player 2.

Ranking harus tetap valid walaupun mobil berada pada posisi fisik yang tidak beraturan akibat collision.

---

# 13. Camera

## Single Player

Menggunakan satu camera yang mengikuti Player 1.

```text
┌────────────────────────────┐
│                            │
│          🚗                │
│             👁 Camera      │
│                            │
└────────────────────────────┘
```

---

## Multiplayer

Screen dibagi menjadi dua viewport.

```text
┌────────────────────────────┐
│        PLAYER 1            │
│                            │
│            🚗              │
│                            │
├────────────────────────────┤
│        PLAYER 2            │
│                            │
│            🚙              │
│                            │
└────────────────────────────┘
```

Player 1 memiliki camera sendiri.

Player 2 memiliki camera sendiri.

Keduanya tetap berada di world yang sama dan dapat berinteraksi/collision dengan seluruh mobil.

---

# 14. HUD

## Race HUD

Minimal menampilkan:

```text
LAP 2 / 3

POSITION
2 / 7

TIME
01:24.32

TURBO
██████░░░░
```

Jika diperlukan, HUD juga dapat menampilkan:

```text
PLAYER 1
```

atau

```text
PLAYER 2
```

pada multiplayer.

---

# 15. Home Screen

Home Screen adalah halaman utama game.

Minimal memiliki:

```text
GAME TITLE

[ SINGLE PLAYER ]

[ MULTIPLAYER ]

[ QUIT ]
```

UI harus sederhana dan mudah dinavigasi.

Tidak diperlukan:

- Account system.
- Online profile.
- Shop.
- Inventory.
- Save data.

---

# 16. Race Setup

Setelah memilih mode, pemain masuk ke Race Setup.

Minimal:

```text
MODE
Single Player / Multiplayer

LAPS
2 / 3

DIFFICULTY
Easy / Normal / Hard

[ START RACE ]
[ BACK ]
```

Difficulty dapat disembunyikan atau diabaikan ketika Multiplayer jika tidak diperlukan.

---

# 17. Results Screen

Setelah race selesai, game menampilkan hasil.

Minimal:

```text
RACE FINISHED

1st   Blue Car       02:31.42
2nd   Red Car        02:34.17
3rd   Yellow Car     02:38.51
4th   Green Car      02:41.02
5th   Purple Car     02:44.33
6th   Orange Car     02:46.90
7th   White Car      02:51.21

BEST LAP
00:48.17

[ PLAY AGAIN ]
[ HOME ]
```

Statistik minimum:

- Final position.
- Total race time.
- Best lap time.
- Finishing order.

---

# 18. Game States

Game menggunakan state yang jelas.

Minimal:

```text
HOME
↓
RACE_SETUP
↓
COUNTDOWN
↓
RACING
↓
RESULTS
```

Optional:

```text
PAUSED
```

State harus dikelola secara terpusat agar perpindahan scene/game state tidak tersebar di berbagai script.

---

# 19. Suggested Scene Architecture

Struktur awal:

```text
scenes/
│
├── main_menu.tscn
├── race_setup.tscn
├── race.tscn
├── results.tscn
│
├── cars/
│   ├── player_car.tscn
│   └── cpu_car.tscn
│
└── tracks/
    └── track_01.tscn
```

Race scene secara konsep:

```text
Race
├── Track
│   ├── Road
│   ├── Boundaries
│   ├── Checkpoints
│   ├── StartGrid
│   └── RacingPath
│
├── Cars
│   ├── Player1
│   ├── Player2
│   ├── CPU1
│   ├── CPU2
│   ├── CPU3
│   ├── CPU4
│   └── CPU5
│
├── Cameras
│   ├── CameraPlayer1
│   └── CameraPlayer2
│
├── RaceManager
└── HUD
```

Node structure dapat berubah ketika implementasi menemukan kebutuhan teknis yang lebih baik, selama behavior MVP tetap terjaga.

---

# 20. Suggested Script Responsibilities

## Car

Menangani:

- Movement.
- Speed.
- Steering.
- Braking.
- Friction.
- Collision-related movement.
- Turbo.

---

## PlayerCar

Menangani:

- Player input.
- Mapping input ke movement.

Tidak menangani:

- Race ranking.
- Lap counting.
- Results.

---

## CPUCar

Menangani:

- AI steering.
- Waypoint target.
- AI acceleration/braking.

Movement dasar tetap berasal dari sistem Car.

---

## RaceManager

Menangani:

- Race state.
- Countdown.
- Lap configuration.
- Race start.
- Race progress.
- Ranking.
- Finish state.
- Race timer.
- Transition ke Results.

---

## Checkpoint

Menangani:

- Deteksi mobil yang melewati checkpoint.
- Urutan checkpoint.
- Progress lap.

---

## GameManager

Menangani hal global seperti:

- Current game mode.
- Selected lap count.
- Difficulty.
- Scene transitions.

Tidak boleh mengambil alih seluruh logic gameplay.

---

# 21. Data Flow

Contoh alur:

```text
Home
 ↓
User selects Multiplayer
 ↓
GameManager
 ↓
Race Setup
 ↓
User selects 3 Laps
 ↓
GameManager stores configuration
 ↓
Race Scene
 ↓
RaceManager initializes
 ↓
Spawn 7 Cars
 ↓
Countdown
 ↓
Race Start
 ↓
Cars move
 ↓
Checkpoints update progress
 ↓
RaceManager updates ranking
 ↓
Cars finish
 ↓
Results
```

---

# 22. MVP Content

MVP hanya membutuhkan:

### Cars

Minimal:

```text
7 visually distinguishable cars
```

Tidak harus memiliki model/statistik berbeda.

Perbedaan warna sudah cukup.

Contoh:

```text
Blue
Red
Yellow
Green
Purple
Orange
White
```

### Track

Minimal:

```text
1 complete race track
```

### UI

Minimal:

```text
Home
Race Setup
Race HUD
Results
```

### Audio

Audio bukan requirement utama MVP.

Jika digunakan:

- Engine sound.
- Collision sound.
- Countdown sound.
- Turbo sound.
- Finish sound.

Audio dapat ditambahkan setelah gameplay sudah stabil.

---

# 23. Out of Scope

Fitur berikut tidak termasuk MVP:

- Online multiplayer.
- LAN multiplayer.
- Account/login.
- Leaderboard online.
- Matchmaking.
- Multiple vehicle classes.
- Vehicle upgrades.
- Vehicle customization.
- Vehicle damage.
- Vehicle destruction.
- Weapons.
- Items/power-ups.
- Money system.
- Shop.
- Garage.
- Story mode.
- Campaign.
- Open world.
- Weather system.
- Day/night cycle.
- Replay system.
- Photo mode.
- Achievements.
- Cloud save.
- Modding system.

Fitur-fitur tersebut boleh dipertimbangkan setelah core game stabil.

---

# 24. Development Priority

Urutan implementasi yang direkomendasikan:

```text
Phase 1
Basic project
↓
Basic car movement
↓
Track
↓
Collision
↓
Camera
```

```text
Phase 2
Checkpoint
↓
Lap system
↓
Race timer
↓
Finish condition
```

```text
Phase 3
CPU AI
↓
7-car race
↓
Ranking
```

```text
Phase 4
Player 2
↓
Second control scheme
↓
Split-screen
```

```text
Phase 5
Turbo
↓
HUD
↓
Countdown
```

```text
Phase 6
Home Screen
↓
Race Setup
↓
Results
↓
Scene transitions
```

```text
Phase 7
Polish
↓
Audio
↓
Visual effects
↓
Balancing
↓
Bug fixing
```

---

# 25. MVP Definition of Done

MVP dianggap selesai apabila skenario berikut dapat dimainkan dari awal sampai akhir tanpa membutuhkan debug/manual intervention:

### Single Player

```text
Open Game
↓
Home
↓
Single Player
↓
Select 3 Laps
↓
Start Race
↓
Countdown
↓
Player drives
↓
6 CPU drives
↓
Cars collide
↓
Player completes 3 laps
↓
Race finishes
↓
Results displayed
↓
Play Again / Home
```

### Multiplayer

```text
Open Game
↓
Home
↓
Multiplayer
↓
Select 3 Laps
↓
Start Race
↓
Countdown
↓
P1 + P2 + 5 CPU
↓
Both players drive simultaneously
↓
Players collide with CPU / each other
↓
Players complete race
↓
Results displayed
↓
Play Again / Home
```

Jika kedua skenario tersebut berjalan dengan baik, maka core MVP telah tercapai.

---

# 26. Design Principles

Project harus mengikuti prinsip berikut:

1. **Gameplay first.**
2. **Simple arcade physics over realistic simulation.**
3. **Local multiplayer is a core feature, not an afterthought.**
4. **Avoid unnecessary systems.**
5. **Prefer simple and maintainable architecture.**
6. **Do not add features before the core race loop is stable.**
7. **New features should extend the existing architecture rather than rewrite working systems.**
8. **Keep the game immediately understandable when played for the first time.**
9. **Collision should create fun interactions without making the game frustrating.**
10. **Visual polish comes after gameplay stability.**

---

# 27. Future Expansion

Setelah MVP stabil, kemungkinan pengembangan:

```text
Multiple Tracks
Vehicle Selection
Different Vehicle Stats
Turbo Pickup
Track Hazards
Power-ups
More CPU Behavior
Vehicle Customization
Local Tournament
Cup Mode
Time Trial
Best Lap Records
More Players / Controllers
```

Future features tidak menjadi bagian dari MVP dan tidak boleh dianggap wajib untuk menyelesaikan versi pertama.

---

# 28. Source of Truth

File ini menjadi baseline untuk pengembangan game.

Jika fitur baru ingin ditambahkan:

1. Tentukan apakah fitur tersebut termasuk MVP atau post-MVP.
2. Jangan mengubah core mechanic tanpa alasan yang jelas.
3. Jangan mengganti sistem yang sudah stabil hanya karena ada pendekatan alternatif.
4. Fitur baru harus kompatibel dengan architecture yang sudah berjalan.
5. Perubahan besar terhadap MVP harus didokumentasikan terlebih dahulu.
6. MVP tetap menjadi batas minimum playable game.

Target utama project:

> **A simple, chaotic, fun 2D local racing game that can be played immediately by one or two people on the same keyboard.**

---

# 29. Implementation Decisions

Keputusan berikut ditetapkan saat implementasi dan mengikat detail yang tidak dispesifikasikan di atas:

1. **Model gerak mobil** — Gaya top-down klasik: arah mobil = arah input. Menekan tombol arah membuat mobil berputar ke arah tersebut sekaligus accelerate; tidak ada input = friction coast; Brake memperlambat; Turbo mempercepat sesuai §8. Tidak ada tombol accelerate terpisah. Input diagonal (gabungan dua tombol arah) didukung (8 arah).
2. **Akhir race** — Race berakhir ketika **seluruh 7 mobil finish**. Mobil yang finish langsung membeku dan collision-nya dinonaktifkan (ghost) agar tidak menghalangi mobil lain di lintasan sempit.
3. **Turbo CPU** — CPU menggunakan turbo, ditembakkan pada jalur lurus saat meter mencukupi.
4. **HUD** — Satu HUD global (bukan per-viewport). Pada multiplayer HUD menampilkan lap/posisi Player 1 dan Player 2 serta bar turbo keduanya.
5. **Fisika & tabrakan** — `CharacterBody2D` memakai `MOTION_MODE_FLOATING`; mobil hanya bertabrakan fisik dengan dinding (mask layer 1). Tabrakan antar mobil diselesaikan manual per pasangan (separasi lingkaran r=22 + impuls medium arcade dari relative velocity) di `RaceManager`, sehingga tidak ada jitter/tumpang tindih. Dinding lintasan berupa polyline kontinu (`CollisionPolygon2D` BUILD_SEGMENTS), bukan rantai kotak. Kecepatan dikoreksi mengikuti perpindahan aktual saat tergesek (mencegah "revving" lalu melesat), knockback meluruh eksponensial, dan turbo yang habis meluruh mulus ke kecepatan normal.
