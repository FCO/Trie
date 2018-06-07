use Trie;
use Test;

my Trie $t1 .= new;
isa-ok $t1, Trie;

my $node = $t1.insert: "bla", 1;
isa-ok $node, Trie;

is $t1.get-node("bla"), $node;
is $t1.get-node("none"), Trie;
is $node.value, 1;

is $t1.single, 1;
is $t1.all, [1];

$t1.insert: "none", 4;
throws-like { $t1.single }, X::Trie::MultipleValues;

is $t1.all, [1, 4];

$t1.insert: "ble", 2;
$t1.insert: "bli", 3;

is $t1.all, [1, 2, 3, 4];

is $t1.get-single("ble"),   2;
is $t1.get-all("bl"),       [1, 2, 3];

is $t1.insert("test").value, "test";
is $t1.get-single("t"), "test";

my @path = $t1.get-path: "test";
is @path.elems, 5;
is @path, [$t1, $t1.get-node("t"), $t1.get-node("te"), $t1.get-node("tes"), $t1.get-node("test")];

done-testing
