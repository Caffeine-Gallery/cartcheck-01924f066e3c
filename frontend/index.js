import { backend } from 'declarations/backend';

const shoppingList = document.getElementById('shopping-list');
const addItemForm = document.getElementById('add-item-form');
const newItemInput = document.getElementById('new-item-input');

async function loadItems() {
    const items = await backend.getItems();
    shoppingList.innerHTML = '';
    items.forEach(item => {
        const li = createListItem(item);
        shoppingList.appendChild(li);
    });
}

function createListItem(item) {
    const li = document.createElement('li');
    li.innerHTML = `
        <input type="checkbox" ${item.completed ? 'checked' : ''}>
        <span>${item.name}</span>
        <button class="delete-btn"><i class="fas fa-trash"></i></button>
    `;

    const checkbox = li.querySelector('input[type="checkbox"]');
    checkbox.addEventListener('change', async () => {
        await backend.updateItem(item.id, checkbox.checked);
    });

    const deleteBtn = li.querySelector('.delete-btn');
    deleteBtn.addEventListener('click', async () => {
        await backend.deleteItem(item.id);
        await loadItems();
    });

    return li;
}

addItemForm.addEventListener('submit', async (e) => {
    e.preventDefault();
    const itemName = newItemInput.value.trim();
    if (itemName) {
        await backend.addItem(itemName);
        newItemInput.value = '';
        await loadItems();
    }
});

// Initial load
loadItems();
