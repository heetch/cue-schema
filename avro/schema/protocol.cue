package schema

Protocol :: {
	protocol: string
	namespace?: string
	doc?: string
	types: [... Schema]
	messages: {
		<name>: Message
	}
}

Message :: {
	doc?: string
	request: [... Field]
	response: Schema
	errors?: [... Schema]
	if response == "null" {
		"one-way"?: bool
	}
}
