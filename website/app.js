// Product catalogue and shopping cart for the Kwaku Online Store demo.
// The cart lives in the visitor's browser only: no orders or payments are processed.

const products = [
  { id: 1, name: "Wireless Headphones", price: 49.99, icon: "🎧" },
  { id: 2, name: "Smart Watch", price: 89.99, icon: "⌚" },
  { id: 3, name: "Laptop Backpack", price: 34.99, icon: "🎒" },
  { id: 4, name: "Running Shoes", price: 59.99, icon: "👟" },
  { id: 5, name: "Digital Camera", price: 199.99, icon: "📷" },
  { id: 6, name: "Gaming Controller", price: 39.99, icon: "🎮" }
];

const cart = [];

const grid = document.getElementById("product-grid");
const cartPanel = document.getElementById("cart-panel");
const cartItems = document.getElementById("cart-items");
const cartCount = document.getElementById("cart-count");
const cartTotal = document.getElementById("cart-total");
const checkoutMessage = document.getElementById("checkout-message");

function money(value) {
  return "£" + value.toFixed(2);
}

function renderProducts() {
  grid.innerHTML = products.map(product => `
    <div class="product-card">
      <div class="product-icon">${product.icon}</div>
      <h3>${product.name}</h3>
      <div class="price">${money(product.price)}</div>
      <button type="button" data-id="${product.id}">Add to cart</button>
    </div>
  `).join("");
}

function renderCart() {
  cartCount.textContent = cart.length;

  if (cart.length === 0) {
    cartItems.innerHTML = "<li>Your cart is empty.</li>";
  } else {
    cartItems.innerHTML = cart.map((item, index) => `
      <li>
        <span>${item.icon} ${item.name}<br><small>${money(item.price)}</small></span>
        <button type="button" data-index="${index}">Remove</button>
      </li>
    `).join("");
  }

  const total = cart.reduce((sum, item) => sum + item.price, 0);
  cartTotal.textContent = money(total);
}

function openCart() {
  cartPanel.classList.add("open");
  cartPanel.setAttribute("aria-hidden", "false");
}

function closeCart() {
  cartPanel.classList.remove("open");
  cartPanel.setAttribute("aria-hidden", "true");
}

grid.addEventListener("click", event => {
  const id = Number(event.target.dataset.id);
  const product = products.find(p => p.id === id);
  if (!product) return;

  cart.push(product);
  checkoutMessage.textContent = "";
  renderCart();
  openCart();
});

cartItems.addEventListener("click", event => {
  if (event.target.dataset.index === undefined) return;
  cart.splice(Number(event.target.dataset.index), 1);
  renderCart();
});

document.getElementById("cart-button").addEventListener("click", openCart);
document.getElementById("close-cart").addEventListener("click", closeCart);

document.getElementById("checkout-button").addEventListener("click", () => {
  if (cart.length === 0) {
    checkoutMessage.textContent = "Add a product first.";
    return;
  }
  checkoutMessage.textContent =
    "Thank you! This is a demo store, so no payment was taken.";
  cart.length = 0;
  renderCart();
});

renderProducts();
renderCart();
