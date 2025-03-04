
// 1- Define a generic struct
#[derive(Drop, Serde)]
struct GenericStruct<T> {
    value: T
}

// 2- Define a struct that uses a generic struct
#[derive(Drop, Serde)]
struct UseGeneric {
    x: u32,
    y: GenericStruct<u8>
}

pub trait DojoStore<T, +Serde<T>> {
    fn serialize(
        self: @T, ref serialized: Array<felt252>,
    ) {
        Serde::serialize(self, ref serialized);
    }
}

pub impl DojoStore_u8 of DojoStore<u8>;
pub impl DojoStore_u32 of DojoStore<u32>;

// DojoStore impl generated for the generic struct `GenericStruct<T>`
pub impl GenericStructDojoStore<T, +DojoStore<T>, +Serde<T>, +Serde<GenericStruct<T>>> of DojoStore<GenericStruct<T>> {
    fn serialize(self: @GenericStruct<T>, ref serialized: Array<felt252>) {
        DojoStore::serialize(self.value, ref serialized);
    }
}

// DojoStore impl generated for the `UseGeneric` struct
impl UseGenericDojoStore of DojoStore<UseGeneric> {
    fn serialize(self: @UseGeneric, ref serialized: Array<felt252>) {
            DojoStore::serialize(self.x, ref serialized);
            DojoStore::serialize(self.y, ref serialized);
    }
}

fn main() {
    let s = UseGeneric { 
        x: 12,
        y: GenericStruct::<u8> { value: 43}
    };
    let mut serialized = array![];
    DojoStore::<UseGeneric>::serialize(@s, ref serialized);
}