# namespace should conform to RFC 1123
# source https://stackoverflow.com/a/20945961/334831
type Kubernetes::Namespace = Pattern['\A(?!-)[a-zA-Z0-9-]{1,63}(?<!-)\z']
