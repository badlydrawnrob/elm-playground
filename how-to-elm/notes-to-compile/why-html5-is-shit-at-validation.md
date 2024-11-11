> HTML forms do not validate on input because HTML5's constraint validation is designed to work in conjunction with JavaScript and the browser's implementation. Here are some reasons why:

1. **Browser differences**: Each browser has its own implementation of HTML5 constraint validation, which can lead to inconsistencies in how forms are validated. For example, some browsers may display validation messages differently, or not at all.
2. **JavaScript required**: HTML5 constraint validation relies on JavaScript to trigger the validation process. If JavaScript is disabled or not supported, forms will not validate on input.
3. **Pattern attribute limitations**: The `pattern` attribute, which is used to define a regular expression for input validation, has limitations. For example, it does not support lookaheads, lookbehinds, or recursive patterns, which can make it difficult to validate complex input formats.
4. **No server-side validation**: HTML5 constraint validation is client-side only, meaning that it does not validate input on the server-side. This means that malicious input can still be submitted to the server if JavaScript is disabled or not supported.
5. **No real-time validation**: HTML5 constraint validation is typically triggered when the form is submitted or when the user leaves the input field. It does not provide real-time validation as the user types, which can lead to errors being detected only after the user has completed the form.
6. **No support for custom validation logic**: HTML5 constraint validation is limited to the built-in validation types (e.g., email, URL, number, date) and does not allow for custom validation logic.

To achieve robust form validation, it's recommended to use a combination of HTML5 constraint validation and JavaScript-based validation. This approach can provide a better user experience and help prevent errors by validating input in real-time and on the server-side.

## Here are some best practices to consider:

1. Use HTML5 constraint validation for basic validation (e.g., required fields, email formats).
2. Use JavaScript-based validation for more complex validation logic (e.g., custom regular expressions, business logic).
3. Validate input on both the client-side (using JavaScript) and server-side (using server-side languages like PHP, Python, or Node.js).
4. Provide clear and concise error messages to users to help them correct their input.
5. Consider using a library or framework that provides robust form validation functionality, such as jQuery Validation or React Hook Form.