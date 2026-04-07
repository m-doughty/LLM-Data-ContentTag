unit class LLM::Data::ContentTag::Tags;

has Bool:D $.nsfw = False;
has Bool:D $.violent = False;
has Bool:D $.gore = False;
has Str @.custom;

method needs-unrestricted-model(--> Bool:D) {
	$!nsfw || $!violent || $!gore;
}

method all-tags(--> List) {
	my @tags;
	@tags.push('nsfw') if $!nsfw;
	@tags.push('violent') if $!violent;
	@tags.push('gore') if $!gore;
	@tags.append(@!custom);
	@tags.list;
}

method to-hash(--> Hash) {
	%(
		nsfw     => $!nsfw,
		violent  => $!violent,
		gore     => $!gore,
		custom   => @!custom.list,
	);
}

method from-hash(%data --> LLM::Data::ContentTag::Tags:D) {
	self.new(
		nsfw     => %data<nsfw> // False,
		violent  => %data<violent> // False,
		gore     => %data<gore> // False,
		custom   => (%data<custom> // []).list,
	);
}
