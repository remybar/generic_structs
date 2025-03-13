// 1- Define a generic struct
#[derive(Drop, Serde)]
struct GenericStruct<T> {
    value: T
}

// 2- Define a struct that uses this generic struct
#[derive(Drop, Serde)]
struct UseGeneric {
    x: u32,
    y: GenericStruct<u8>
}

// DojoStore with a default implementation based on Serde.
pub trait DojoStore<T, +Serde<T>> {
    fn ser(
        self: @T, ref serialized: Array<felt252>,
    ) {
        Serde::serialize(self, ref serialized);
    }
}

// Use default implementation for primitive types
pub impl DojoStore_u8 of DojoStore<u8>;
pub impl DojoStore_u32 of DojoStore<u32>;

// DojoStore impl generated for the generic struct `GenericStruct<T>` (through a derive attribute)
pub impl GenericStructDojoStore<
    T,
    +DojoStore<T>,
    +Serde<T>,
    +Serde<GenericStruct<T>>
> of DojoStore<GenericStruct<T>> {
    fn ser(self: @GenericStruct<T>, ref serialized: Array<felt252>) {
        // Here, we should use a custom implementation of generic struct serialization to
        // call DojoStore::ser on every struct members.
        DojoStore::ser(self.value, ref serialized);
    }
}

// DojoStore impl generated for the `UseGeneric` struct (through a derive attribute)
impl UseGenericDojoStore of DojoStore<UseGeneric> {
    fn ser(self: @UseGeneric, ref serialized: Array<felt252>) {
        // Here, we should use a custom implementation of struct serialization to
        // call DojoStore::ser on every struct members.
        DojoStore::ser(self.x, ref serialized);
        DojoStore::ser(self.y, ref serialized);
    }
}

// == Solution 1: nothing more, should work like Serde implementation.

// == Solution 2: specialize the GenericStructDojoStore<T> impl for `u8` to help the compiler.
// -> error: "Cycle detected while resolving 'impls alias' items".

//impl GenericStructDojoStoreU8 = GenericStructDojoStore<u8>;

// == Solution 3: directly generate an impl for `GenericStruct<u8>`
// -> unfortunately, this is not possible in our case as these impls are generated
// through a derive attribute and we don't know if it has been already generated from
// another location (another struct member for example) or not.

//pub impl GenericStructDojoStoreU8 of DojoStore<GenericStruct<u8>> {
//    fn ser(self: @GenericStruct<u8>, ref serialized: Array<felt252>) {
//        DojoStore::ser(self.value, ref serialized);
//    }
//}

#[derive(Drop, Serde)]
enum E1 {
    X,
    Y
}

fn main() {
    let mut serialized = array![];

    let x = E1::X;
    Serde::serialize(@x, ref serialized);
    println!("serialized: {:?}", serialized)
}