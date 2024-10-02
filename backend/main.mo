import Bool "mo:base/Bool";
import Func "mo:base/Func";
import Hash "mo:base/Hash";
import List "mo:base/List";

import Array "mo:base/Array";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Option "mo:base/Option";
import Text "mo:base/Text";

actor {
  // Define the ShoppingItem type
  type ShoppingItem = {
    id: Nat;
    name: Text;
    completed: Bool;
  };

  // Stable variable to store the shopping list
  stable var nextId: Nat = 0;
  stable var shoppingListEntries: [(Nat, ShoppingItem)] = [];

  // Create a HashMap to store the shopping list
  var shoppingList = HashMap.fromIter<Nat, ShoppingItem>(shoppingListEntries.vals(), 10, Nat.equal, Nat.hash);

  // Function to add a new item to the shopping list
  public func addItem(name: Text) : async Nat {
    let id = nextId;
    let newItem: ShoppingItem = {
      id = id;
      name = name;
      completed = false;
    };
    shoppingList.put(id, newItem);
    nextId += 1;
    id
  };

  // Function to get all items in the shopping list
  public query func getItems() : async [ShoppingItem] {
    Iter.toArray(shoppingList.vals())
  };

  // Function to update the completed status of an item
  public func updateItem(id: Nat, completed: Bool) : async Bool {
    switch (shoppingList.get(id)) {
      case (null) { false };
      case (?item) {
        let updatedItem: ShoppingItem = {
          id = item.id;
          name = item.name;
          completed = completed;
        };
        shoppingList.put(id, updatedItem);
        true
      };
    }
  };

  // Function to delete an item from the shopping list
  public func deleteItem(id: Nat) : async Bool {
    switch (shoppingList.remove(id)) {
      case (null) { false };
      case (?_) { true };
    }
  };

  // Pre-upgrade hook to save the shopping list
  system func preupgrade() {
    shoppingListEntries := Iter.toArray(shoppingList.entries());
  };

  // Post-upgrade hook to restore the shopping list
  system func postupgrade() {
    shoppingList := HashMap.fromIter<Nat, ShoppingItem>(shoppingListEntries.vals(), 10, Nat.equal, Nat.hash);
  };
}
