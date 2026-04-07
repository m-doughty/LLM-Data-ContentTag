unit class LLM::Data::ContentTag::Tags;

has Bool %.tags;
has Str @.restricted;  # Tag names that require an unrestricted model

method has-tag(Str:D $tag --> Bool:D) {
	%!tags{$tag} // False;
}

method needs-unrestricted-model(--> Bool:D) {
	so @!restricted.first({ %!tags{$_} });
}

method all-tags(--> List) {
	%!tags.keys.grep({ %!tags{$_} }).sort.list;
}

method to-hash(--> Hash) {
	%(
		tags       => %!tags.Hash,
		restricted => @!restricted.list,
	);
}

method from-hash(%data --> LLM::Data::ContentTag::Tags:D) {
	my Str @restricted = (%data<restricted> // []).list;
	my %tags;
	for (%data<tags> // %()).kv -> Str $k, $v {
		%tags{$k} = ?$v;
	}
	self.new(:%tags, :@restricted);
}
