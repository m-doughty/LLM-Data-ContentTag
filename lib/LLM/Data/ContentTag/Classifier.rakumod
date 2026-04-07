use LLM::Data::ContentTag::Tags;

unit class LLM::Data::ContentTag::Classifier;

# Tag name → list of keywords that trigger it
has %.rules;
has Str @.restricted;  # Which tag names require an unrestricted model

method classify(Str:D $content --> LLM::Data::ContentTag::Tags:D) {
	my Str:D $lower = $content.lc;
	my Bool %tags;
	for %!rules.kv -> Str:D $tag, $keywords {
		%tags{$tag} = so $keywords.list.first({ $lower.contains($_) });
	}
	LLM::Data::ContentTag::Tags.new(:%tags, :@!restricted);
}

method classify-from-metadata(%metadata --> LLM::Data::ContentTag::Tags:D) {
	my Bool %tags;
	for %metadata.kv -> Str:D $k, $v {
		%tags{$k} = ?$v;
	}
	LLM::Data::ContentTag::Tags.new(:%tags, :@!restricted);
}
