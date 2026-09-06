# EMUBooks

EMUBooks is a console-based bookstore management system written entirely in x86 assembly (8086, MASM syntax). It simulates a simplified e-commerce workflow for an online bookstore, supporting two distinct user roles, stock management, an out-of-stock request pipeline, a shopping cart with automatic billing, and a built-in discount scheme for BRAC University students.

The entire application runs inside a single `.asm` file using DOS interrupts (`INT 21H`, `INT 10H`) for input/output, with no external dependencies beyond a DOS-compatible assembler and runtime environment (e.g., DOSBox, MASM/TASM, or an 8086 emulator).

## Table of Contents

- [Overview](#overview)
- [User Roles](#user-roles)
- [Features](#features)
- [Menu Structure](#menu-structure)
- [Discount Rule](#discount-rule)
- [Sample Catalog](#sample-catalog)
- [Getting Started](#getting-started)
- [Project Structure Notes](#project-structure-notes)
- [Known Limitations](#known-limitations)
- [License](#license)

## Overview

EMUBooks was built as an academic assembly language project to demonstrate low-level implementation of common application logic, including string handling, user authentication, in-memory data storage, arithmetic operations, and conditional branching, without the benefit of high-level language constructs or persistent storage.

All data (registered users, stock levels, cart contents, pending requests, and analytics counters) is held in memory for the duration of a single program run and is reset when the program exits.

## User Roles

The system supports two types of users:

1. **Owner (Admin)**
   The website administrator account. The admin has a fixed, predefined set of login credentials and is granted access to store management features that are hidden from regular buyers.

2. **Buyer**
   Any user other than the admin. A buyer must sign up with an email and password before they are able to log in. Once registered, a buyer can log in using their credentials to browse and purchase books.

A user can log out at any time, which returns the session to the login/sign-up screen and clears the current session state (login status, admin flag, and BRACU discount eligibility).

## Features

### 1. Login and Sign Up

- New users register with an email and password via the sign-up screen.
- Returning users log in with their registered email and password.
- The admin account uses a fixed, predefined email and password and does not go through the sign-up flow; admin credentials are checked first on every login attempt.
- Login attempts are limited; repeated invalid attempts return the user to the login/sign-up selection screen.
- A logged-in user (admin or buyer) can log out at any time, returning to the root login/sign-up page.

### 2. Stock Management (Admin Only)

- The admin can view the full book catalog along with current stock levels and prices.
- The admin can add stock to any existing book in the catalog.
- If a book that had pending out-of-stock requests is restocked, those pending requests are automatically cleared and counted toward the all-time "requests handled" total, and the admin is notified of how many users were waiting.

### 3. Shop Analytics (Admin Only)

The admin can view a summary of store performance, including:

- Total number of book titles in the catalog
- Total stock quantity across all books
- Number of pending out-of-stock requests
- Total number of requests fulfilled over the lifetime of the session
- The single most-requested out-of-stock book and how many times it was requested

### 4. Purchase Books (Buyer)

- Buyers can browse the catalog and add in-stock books to a shopping cart.
- Stock availability is checked before a book can be added or its quantity increased.

### 5. Request an Out-of-Stock Book (Buyer)

- If a book is out of stock, a buyer can submit a request for that book.
- Requests are tracked per book and surfaced to the admin through the "Handle Requests" screen.

### 6. Handle Out-of-Stock Requests (Admin Only)

- The admin can view all books with pending requests and restock them directly from this screen.
- Restocking a requested book clears its pending request count and updates the all-time fulfilled-requests counter.

### 7. Shopping Cart

- Add a book to the cart with a specified quantity (validated against current stock).
- Remove a book from the cart.
- Change the quantity of a book already in the cart.
- View the current cart contents, including per-item quantity, price, and a running subtotal and item count.
- The cart persists in memory only for the duration of the buyer's session.

### 8. Automatic Bill Generation

- At checkout, the system automatically calculates:
  - Total number of items
  - Subtotal (before discount)
  - Discount amount, if applicable
  - Final payable amount
- On checkout, the corresponding stock quantities are deducted from the catalog and the cart is cleared.

### 9. Discount for BRACU Students

- Users who sign up and log in with a valid BRAC University Google Workspace email address (ending in `@g.bracu.ac.bd`) are flagged as BRACU students at login.
- BRACU students receive a 20% discount on the subtotal at checkout, provided the cart contains three or more total items.
- If the discount threshold is not met, or the user is not identified as a BRACU student, no discount is applied and this is clearly indicated on the generated bill.

## Menu Structure

After logging in, the main menu presented depends on the user's role:

**Admin Menu**
1. View Book Stock
2. Update Stock
4. Handle Out-of-Stock Requests
5. View Shop Analytics
9. Logout

**Buyer Menu**
1. View Book Stock
3. Request an Out-of-Stock Book
6. Purchase Books (Shopping Cart)
9. Logout

**Shopping Cart Sub-Menu (Buyer)**
1. Add Book
2. Remove Book
3. Change Quantity
4. View Cart
6. Automatic Bill / Checkout
0. Go Back

## Discount Rule

| Condition                                              | Result                          |
|---------------------------------------------------------|----------------------------------|
| BRACU email at signup/login AND cart has 3+ items        | 20% discount applied to subtotal |
| Non-BRACU email, or cart has fewer than 3 items          | No discount applied              |

## Sample Catalog

The store ships with a fixed catalog of 8 books, each with an initial stock level and price:

| # | Title                          | Initial Stock | Price |
|---|---------------------------------|----------------|-------|
| 1 | Harry Potter                    | 0              | 350   |
| 2 | Khoabnama                        | 3              | 250   |
| 3 | Lalshalu                         | 2              | 200   |
| 4 | The Brief History of Time        | 1              | 450   |
| 5 | Deyal                             | 0              | 220   |
| 6 | Pather Panchali                   | 5              | 300   |
| 7 | Sapiens                            | 7              | 500   |
| 8 | Ekattorer Dinguli                  | 4              | 280   |

## Getting Started

EMUBooks is written for the 8086 architecture using MASM-style syntax and DOS interrupts, so it requires a DOS environment (real or emulated) to assemble and run.

### Prerequisites

- An 8086/DOS assembler and linker (e.g., MASM, TASM, or an equivalent toolchain)
- A DOS environment or emulator capable of running 16-bit `.exe` files (e.g., DOSBox)

### Assembling and Running

Using MASM/TASM inside a DOS environment or DOSBox:

```
MASM EMUBooks_Final.asm;
LINK EMUBooks_Final.obj;
EMUBooks_Final.exe
```

Exact commands may vary slightly depending on the specific assembler/linker toolchain used.

### Default Admin Credentials

The admin account is predefined in the source and does not require sign-up:

- **Email:** `admin`
- **Password:** `admin`

## Project Structure Notes

The project is contained in a single assembly source file, organized into clearly delimited sections:

- **Macros** — reusable building blocks for screen clearing, string/character printing, numeric input validation, and page titles.
- **Data Segment** — string literals, the book catalog, user storage buffers, cart state, and analytics counters.
- **Login/Sign-Up Logic** — credential validation for both the admin and registered buyers, including duplicate-email checks and BRACU email domain detection.
- **Stock and Request Logic** — stock updates, out-of-stock request submission, and request fulfillment.
- **Analytics** — aggregation of stock, request, and fulfillment statistics.
- **Shopping Cart and Checkout** — cart operations (add/remove/change/view) and automatic bill generation with discount logic.

## Known Limitations

- All data is held in memory only; nothing persists once the program exits.
- The user store, cart, and catalog are all fixed-size, in-memory buffers sized for a small number of users and 8 books.
- Input is limited to single-digit numeric selections, consistent with DOS-era console interaction.
- There is no encryption or hashing of stored passwords; credentials are stored and compared as plain text, which is acceptable for an academic simulation but not suitable for production use.

## License

This project was developed for academic purposes. 
