// fixture for report verification
const input = process.argv[2];
const query = "SELECT * FROM users WHERE id = " + input; // critical SQL injection CWE-89
// high severity: empty catch
try { doSomething(); } catch(e) {}
// nitpick: typo fix hint
// teh typo is here
console.log("debug leftover");
