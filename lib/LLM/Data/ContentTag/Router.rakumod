use LLM::Data::ContentTag::Tags;

unit class LLM::Data::ContentTag::Router;

# Maps route names to backend identifiers.
# The "unrestricted" route handles content that needs an uncensored model.
# The "default" route handles safe content.
has Str $.default-backend is required;
has Str $.unrestricted-backend is required;
has %!custom-routes;

method add-route(Str:D $tag, Str:D $backend --> Nil) {
	%!custom-routes{$tag} = $backend;
}

method select-backend(LLM::Data::ContentTag::Tags:D $tags --> Str:D) {
	# Check custom routes first (most specific match)
	for $tags.all-tags -> Str:D $tag {
		return %!custom-routes{$tag} if %!custom-routes{$tag}:exists;
	}

	# Fall back to unrestricted/default
	$tags.needs-unrestricted-model ?? $!unrestricted-backend !! $!default-backend;
}
