# EMUBooks
## Features

### 1. Login and Logout

The system supports two types of users:

* **Owner:** The Owner is the Admin account responsible for performing administrative tasks and managing the overall operations of the bookstore.
* **Buyer:** Any user other than the Owner is considered a Buyer.

The authentication system provides the following functionality:

* New users can **sign up** using an email address and password.
* Registered users can **log in** using their credentials.
* The Owner has a **predefined email address and password** for accessing the administrative features.
* Both Owners and Buyers can **log out** at any time.

### 2. Updating Stock

This feature is restricted to the **Owner/Admin**.

The Admin can:

* Add new books to the store.
* Increase the stock quantity of existing books.
* Remove existing books from the store.

### 3. View Shop Analytics

The **Owner/Admin** can view the overall analytics of the bookstore, including:

* Total sales
* Customer reviews
* Book requests
* Current stock condition

### 4. Purchase Books

A registered **Buyer** can purchase books that are currently available and in stock.

The system verifies the availability of the selected books before completing the purchase.

### 5. Request for Out-of-Stock Books

If a desired book is currently out of stock, a **Buyer** can submit a request for that specific book.

The request can then be reviewed and managed by the **Owner/Admin**.

### 6. Rate Purchased Books

Buyers who have purchased a book can provide a rating from **1 to 5** based on their experience with the book.

Only books that have been purchased by the Buyer can be rated.

### 7. Shopping Cart

The shopping cart keeps track of the books selected by a Buyer before checkout.

Buyers can:

* Add books to the cart.
* Remove books from the cart.
* Adjust the quantity of selected books.
* Purchase the selected books during checkout.

### 8. Sorting Books

Both **Owner/Admin** and **Buyers** can sort the available books based on their **user ratings**.

### 9. Search Books

Both **Owner/Admin** and **Buyers** can search for books using:

* Book ID
* Author name
* Book title

This allows users to quickly locate specific books in the store.

### 10. Automatic Bill Generation

During checkout, the system automatically:

1. Calculates the total cost based on the selected books and their quantities.
2. Determines whether the Buyer is eligible for any applicable discount.
3. Applies the discount when the eligibility conditions are satisfied.
4. Generates the final bill for the purchase.

### 11. Discount for BRACU Students

Users who sign up using a **valid BRACU student G Suite email address** are eligible for a **20% discount** when purchasing **three or more items**.

The discount is automatically applied to the final amount during checkout when all eligibility conditions are satisfied.
