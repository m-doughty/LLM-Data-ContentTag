use LLM::Data::ContentTag::Tags;

unit class LLM::Data::ContentTag::Router;

has Str $.default-backend is required;
has @!routes;  # List of { tags => [tag names], backend => Str }

method add-route(Str:D $backend, *@tags --> Nil) {
	@!routes.push: %(:@tags, :$backend);
}

method select-backend(LLM::Data::ContentTag::Tags:D $tags --> Str:D) {
	# Check routes in order — first match wins
	for @!routes -> %route {
		my Bool:D $match = so %route<tags>.list.first({ $tags.has-tag($_) });
		return %route<backend> if $match;
	}
	$!default-backend;
}
