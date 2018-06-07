use X::Trie::MultipleValues;
unit class Trie;
has ::?CLASS    %!children;
has             $.value     = Nil;

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
    [
        |($_ with $!value),
        |%!children.pairs.sort(*.key).hyper(:1batch).map: *.value.all
    ]
}

method children { %!children.elems }

#method delete-path(@path) {
#    for @path.reverse -> $node {
#        if $node.children + ($node.value.DEFINITE ?? 1 !! 0) > 1 {
#
#        }
#    }
#}
#
#method delete(@chars) {
#    self.delete-path: self.get-path: @chars
#}
#
#method delete(Str() $key) { self.delete: $key.comb }

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
