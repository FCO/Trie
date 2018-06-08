use X::Trie::MultipleValues;
unit class Trie does Associative;
trusts Trie;
has ::?CLASS    %.children;
has             $.value     = Nil;

method AT-KEY(::?CLASS:D: $key) {
    self.get-all: $key
}

method EXISTS-KEY(::?CLASS:D: $key) {
    ?self.get-node: $key
}

method DELETE-KEY(::?CLASS:D: $key) {
    my \value = self{$key};
    self.delete: $key;
    value
}

method ASSIGN-KEY(::?CLASS:D: $key, $value) {
    self.insert: $key, $value
}

multi method insert([], $data) {
    die "Value already set" with $!value;
    $!value = $data;
    self
}

multi method insert([$first, *@arr], $data) {
    (%!children{$first} //= ::?CLASS.new).insert: @arr, $data
}

multi method insert(Str $string, $data = $string) {
    self.insert: $string.comb, $data
}

method single {
    do with $!value {
        X::Trie::MultipleValues.new.throw if %!children.elems;
        $!value
    } elsif %!children.elems > 1 {
        X::Trie::MultipleValues.new.throw if %!children.elems;
    } elsif %!children.elems == 1 {
        %!children.values.first.single
    }
}

method all {
    gather {
        self!all
    }
}

method !all {
    return unless self.DEFINITE;
    .take with $!value;
    %!children.pairs.sort(*.key)>>.value>>!all
}

method children { %!children.elems }

method !children-and-value { %!children.elems + ($!value.DEFINITE ?? 1 !! 0) }

multi method delete(@arr) { self.del(@arr, :root) }

multi method delete(Str() $key) { self.delete: $key.comb }

multi method del([], :$root) {
    return unless self.DEFINITE;
    $!value = Nil;
    not %!children.elems
}

multi method del([$first, *@arr], Bool :$root) {
    my Bool $del = %!children{$first}.del: @arr;
    do if $root or self!children-and-value > 1 {
        if $del {
            %!children{$first}:delete
        }
        False
    } else {
        $del
    }
}

multi method get-path([]) { [ self ] }

multi method get-path([$first, *@arr]) {
    return Trie unless %!children{$first}:exists;
    [ self, |%!children{$first}.get-path: @arr ]
}

multi method get-path(Str $string) {
    self.get-path: $string.comb
}

multi method get-node { self }

multi method get-node([]) { self.get-node }

multi method get-node([$first, *@arr]) {
    return Trie unless %!children{$first}:exists;
    %!children{$first}.get-node: @arr
}

multi method get-node(Str $string) {
    self.get-node: $string.comb
}

method get-single(\key) { self.get-node(key).single }
method get-all(\key) { self.get-node(key).all }
