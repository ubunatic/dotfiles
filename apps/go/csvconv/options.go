package csvconv

import "ubunatic.com/dotapps/go/csvconv/converters"

type Opt func(*options)

type options struct {
	srcDelimiter rune
	dstDelimiter rune
	outputMode   NLMode
	converters   []converters.Converter
	inline       bool
}

func newOptions(opts ...Opt) *options {
	o := &options{
		srcDelimiter: ',',
		outputMode:   AutoCRLF,
		converters:   []converters.Converter{},
		inline:       false,
	}
	o.apply(opts...)
	return o
}

func (o *options) apply(opts ...Opt) {
	for _, opt := range opts {
		opt(o)
	}
	if o.dstDelimiter == 0 {
		o.dstDelimiter = o.srcDelimiter
	}
}

func WithDelimiters(srcDelim, dstDelim rune) Opt {
	return func(opts *options) {
		opts.srcDelimiter = srcDelim
		opts.dstDelimiter = dstDelim
	}
}

func WithOutputMode(outputMode NLMode) Opt {
	return func(opts *options) {
		opts.outputMode = outputMode
	}
}

func With(converters ...converters.Converter) Opt {
	return func(opts *options) {
		opts.converters = append(opts.converters, converters...)
	}
}

func WithInline(inline bool) Opt {
	return func(opts *options) {
		opts.inline = inline
	}
}
