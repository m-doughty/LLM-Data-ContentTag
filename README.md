[![Actions Status](https://github.com/m-doughty/LLM-Data-ContentTag/actions/workflows/test.yml/badge.svg)](https://github.com/m-doughty/LLM-Data-ContentTag/actions)

NAME
====

LLM::Data::ContentTag - Content classification and model routing for LLM data pipelines

SYNOPSIS
========

```raku
use LLM::Data::ContentTag;

# Classify content by keywords
my $classifier = LLM::Data::ContentTag::Classifier.new;
my $tags = $classifier.classify('An explicit scene with violence.');
say $tags.nsfw;                      # True
say $tags.violent;                   # True
say $tags.needs-unrestricted-model;  # True
say $tags.all-tags;                  # (nsfw, violent)

# Classify from metadata (e.g., chapter annotations)
my $tags2 = $classifier.classify-from-metadata(%(
    is_nsfw => True,
    custom_tags => ['dark-humor'],
));

# Custom keyword lists
my $custom = LLM::Data::ContentTag::Classifier.new(
    :nsfw-keywords('lewd', 'suggestive', 'explicit'),
    :violent-keywords('combat', 'warfare'),
);

# Route to appropriate LLM backend
my $router = LLM::Data::ContentTag::Router.new(
    :default-backend('claude-api'),
    :unrestricted-backend('local-kobold'),
);
say $router.select-backend($tags);   # "local-kobold"

# Custom per-tag routes
$router.add-route('dark-humor', 'humor-specialist');
```

DESCRIPTION
===========

LLM::Data::ContentTag provides content classification and model routing for LLM data generation pipelines.

LLM::Data::ContentTag::Tags
---------------------------

Immutable content tag set for a piece of content.

```raku
my $t = LLM::Data::ContentTag::Tags.new(
    :nsfw,                    # Bool, default False
    :violent,                 # Bool, default False
    :gore,                    # Bool, default False
    :custom('tag1', 'tag2'),  # Str array, default empty
);

$t.nsfw;                      # Bool
$t.violent;                   # Bool
$t.gore;                      # Bool
$t.custom;                    # List of Str
$t.needs-unrestricted-model;  # True if any of nsfw/violent/gore
$t.all-tags;                  # Combined list of active tag names
$t.to-hash;                   # Serializable Hash
LLM::Data::ContentTag::Tags.from-hash(%data);  # Deserialize
```

LLM::Data::ContentTag::Classifier
---------------------------------

Assigns tags to content. Rule-based keyword detection with customizable word lists.

```raku
my $c = LLM::Data::ContentTag::Classifier.new(
    :nsfw-keywords('explicit', 'nude'),       # Override defaults
    :violent-keywords('kill', 'murder'),
    :gore-keywords('gore', 'dismember'),
);

$c.classify(Str $content --> Tags);           # Classify by keywords
$c.classify-from-metadata(%meta --> Tags);    # Classify from metadata hash
```

Metadata keys: `nsfw`/`is_nsfw`, `violent`/`is_violent`, `gore`/`is_gore`, `custom_tags`.

LLM::Data::ContentTag::Router
-----------------------------

Maps content tags to LLM backend identifiers.

```raku
my $r = LLM::Data::ContentTag::Router.new(
    :default-backend('safe-model'),
    :unrestricted-backend('uncensored-model'),
);

$r.add-route('dark-humor', 'special-model');  # Per-tag override
$r.select-backend($tags --> Str);              # Returns backend name
```

Priority: custom per-tag routes > unrestricted (if any restricted flag) > default.

AUTHOR
======

Matt Doughty <matt@apogee.guru>

COPYRIGHT AND LICENSE
=====================

Copyright 2026 Matt Doughty

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

