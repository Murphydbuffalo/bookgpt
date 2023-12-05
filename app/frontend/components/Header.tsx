import '../stylesheets/Header.css';

export default function Header() {
  return (
    <header>
      <div className='invisible header-item'></div>

      <div>
        <h1>Ask The Mom Test</h1>
        <p>
          <a href='https://hailpixel.gumroad.com/l/momtest' target='_blank'>Buy on Gumroad</a>
        </p>
      </div>
      
      <a href='https://hailpixel.gumroad.com/l/momtest' target='_blank'>
        <img className='header-item' width="200px" src='/vite/assets/momtest-fCbclsqR.webp' />
      </a>
    </header>
  );
};
