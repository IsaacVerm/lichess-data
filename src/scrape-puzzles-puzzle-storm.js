const runId = crypto. randomUUID();
const now = new Date();
const date = now.toISOString().split('T')[0]; // YYYY-MM-DD
const time = now.toTimeString().split(' ')[0]; // HH:MM:SS in 24-hour format

console.log(
  Array.from(document.querySelectorAll('.puz-history__round')).map(round => {
    const resultElement = round.querySelector('good') || round.querySelector('bad');
    const rating = parseInt(round. querySelector('rating').textContent);
    const href = round.querySelector('a').getAttribute('href');
    const result = round.querySelector('good') ? 'good' : 'bad';
    const clock = parseInt(resultElement.textContent);
    return `${runId},${date},${time},${rating},${href},${result},${clock}`;
  }).join('\n')
)
