async function loadProducts() {
    const response = await fetch("https://fakestoreapi.com/products");
    const products = await response.json();
    displayProducts(products);  
}

function displayProducts(products) {

    // Find the container where products will be displayed
    const container = document.querySelector('#all-products .container');

   
    // Iterate over each product and create the HTML structure safely
    products.forEach(product => {
        // Create the main product div
        const productElement = document.createElement('div');
        productElement.classList.add('product');

        // Create the product picture div
        const pictureDiv = document.createElement('div');
        pictureDiv.classList.add('product-picture');
        const img = document.createElement('img');
        img.src = product.image;
        img.alt = `product: ${product.title}`;
        pictureDiv.appendChild(img);

        // Create the product info div
        const infoDiv = document.createElement('div');
        infoDiv.classList.add('product-info');

        const category = document.createElement('h5');
        category.classList.add('categories');
        category.textContent = product.category;

        const title = document.createElement('h4');
        title.classList.add('title');
        title.textContent = product.title;

        const price = document.createElement('h3');
        price.classList.add('price');
        const priceSpan = document.createElement('span');
        priceSpan.textContent = `US$ ${product.price}`;
        price.appendChild(priceSpan);

        const button = document.createElement('button');
        button.textContent = 'Add to bag';

        // Append elements to the product info div
        infoDiv.appendChild(category);
        infoDiv.appendChild(title);
        infoDiv.appendChild(price);
        infoDiv.appendChild(button);

        // Append picture and info divs to the main product element
        productElement.appendChild(pictureDiv);
        productElement.appendChild(infoDiv);

        // Append the new product element to the container
        container.appendChild(productElement);
    });

    

}



loadProducts();

// Lint errors introduced:
var unusedVariable = "this will cause a lint error";
let anotherUnusedVar = 42;
const yetAnotherUnused = true;

// Missing semicolon (if configured)
var noSemicolon = "missing semicolon"

// Unreachable code after return
function badFunction() {
    return "this returns";
    console.log("this will never execute"); // unreachable code
}

// Using undefined variable
function useUndefined() {
    return someUndefinedVariable + 5;
}
