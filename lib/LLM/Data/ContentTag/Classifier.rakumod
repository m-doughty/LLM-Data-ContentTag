use LLM::Data::ContentTag::Tags;

unit class LLM::Data::ContentTag::Classifier;

# Keyword lists for rule-based classification
has Str @.nsfw-keywords = <sex nude naked explicit hentai>;
has Str @.violent-keywords = <kill murder stab shoot blood fight war>;
has Str @.gore-keywords = <gore dismember mutilate entrails>;

method classify(Str:D $content --> LLM::Data::ContentTag::Tags:D) {
	my Str:D $lower = $content.lc;
	LLM::Data::ContentTag::Tags.new(
		nsfw     => self!matches-any($lower, @!nsfw-keywords),
		violent  => self!matches-any($lower, @!violent-keywords),
		gore     => self!matches-any($lower, @!gore-keywords),
	);
}

method classify-from-metadata(%metadata --> LLM::Data::ContentTag::Tags:D) {
	LLM::Data::ContentTag::Tags.new(
		nsfw     => ?(%metadata<nsfw> // %metadata<is_nsfw> // False),
		violent  => ?(%metadata<violent> // %metadata<is_violent> // False),
		gore     => ?(%metadata<gore> // %metadata<is_gore> // False),
		custom   => (%metadata<custom_tags> // []).list,
	);
}

method !matches-any(Str:D $text, @keywords --> Bool:D) {
	so @keywords.first({ $text.contains($_) });
}
