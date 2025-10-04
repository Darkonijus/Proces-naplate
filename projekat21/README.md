
# Capi Bar – Delphi 12 POS (Skeleton)

Ovo je minimalni projekat usklađen sa SSA/IDEF0/MOV modelom koji smo uradili.

## Kako pokrenuti

1. **Kopiraj `cafebar.db`** pored `NaplataApp.dpr` (ili pusti da aplikacija sama kreira bazu po šemi).
2. Otvori **Delphi 12 (RAD Studio)** → *Open Project* → `NaplataApp.dpr`.
3. Build & Run.

> Aplikacija koristi **FireDAC + SQLite**. Driver je uključen kroz `FDPhysSQLiteDriverLink` u `uDM.pas`.

### Nalog/seed
- Radnik: `radnik / 1234` (za sada korišćen ID=1 bez login forme)
- Menadžer: `menadzer / 9999`
- Metodi plaćanja: `CASH`, `CARD`

### Ekrani
- **frmMain** – mreža stolova (1–24), *Zatvori dan*.
- **frmOrder** – stavke porudžbine (dodaj/ukloni), total.
- **frmPayment** – gotovina/kartica/mix, *Izdaj račun* (generiše `receipt_no`).
- **frmCloseDay** – brzi X/Z izveštaj po metodu (sumarne sume).

## Šema baze (ukratko)

- `worker`, `shift`, `item`, `"order"` (quoted), `order_item`, `payment_method`, `payment`
- `EnsureSchema` kreira/alteriše tabele ako ne postoje.

## Dalje
- UI se može stilizovati prema Figma maketama (keypad, grid artikala, VIP popust, PIN menadžera).
- Ako koristiš postojeći `cafebar.db`, program će ga otvoriti i po potrebi dodati manjkajuće tabele/kolone.

