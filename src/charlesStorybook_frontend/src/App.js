import { html, render } from 'lit-html';
//import { charlesStorybook_backend } from 'declarations/charlesStorybook_backend';
import leftPage from './leftPage.png';
import rightPage from './rightPage.png';

import {PageFlip} from 'page-flip';


class App {
  greeting = '';

  constructor() {
    this.#render();
  }

  #handleSubmit = async (e) => {
    e.preventDefault();
    const name = document.getElementById('name').value;
    //this.greeting = await charlesStorybook_backend.greet(name);
    this.#render();
  };

  #render() {
    let body = html`
      <main>
        <div class="container">
          <div>
              <button type="button" class="btn-prev">Previous page</button>
              [<span class="page-current">1</span> of <span class="page-total">-</span>]
              <button type="button" class="btn-next">Next page</button>
          </div>

          <div>
              State: <i class="page-state">read</i>, orientation: <i class="page-orientation">landscape</i>
          </div>
        </div>

        <div class="container">
          <div class="flip-book" id="book">
              <div class="page page-cover page-cover-top" data-density="hard">
                  <div class="page-content">
                      <h2>BOOK TITLE</h2>
                      <div class="page-image" style="background-image: url(./leftPage.png)"></div>
                  </div>
              </div>
              <div class="page">
                  <div class="page-content">
                      <h2 class="page-header">Page header 1</h2>
                      
                      <div class="page-text">Lorem ipsum  </div>
                      <div class="page-footer">2</div>
                  </div>
              </div>
              <!-- PAGES .... -->
              <div class="page">
                  <div class="page-content">
                      <h2 class="page-header">Page header - 15</h2>
                      <!-- <div class="page-image" style="background-image: url(./leftPage.png)"></div> -->
                      <div class="page-text">Lorem ipsum  </div>
                      <div class="page-footer">16</div>
                  </div>
              </div>
              <div class="page">
                  <div class="page-content">
                      <h2 class="page-header">Page header - 16</h2>
                      <!-- <div class="page-image" style="background-image: url(./rightPage.png)"></div> -->
                      <div class="page-text">Lorem ipsum  </div>
                      <div class="page-footer">17</div>
                  </div>
              </div>
              <div class="page page-cover page-cover-bottom" data-density="hard">
                  <div class="page-content">
                      <h2>THE END</h2>
                      <!-- <div class="page-image" style="background-image: url(./leftPage.png)"></div> -->
                  </div>
              </div>
              <div class="page page-cover page-cover-bottom" data-density="hard">
                  <div class="page-content">
                      <!-- <div class="page-image" style="background-image: url(./rightPage.png)"></div> -->
                  </div>
              </div>
          </div>
        </div>
      </main>
    `;

    render(body, document.getElementById('root'));
    const pageFlip = new PageFlip(document.getElementById('book'), {
      width: 550, // base page width
      height: 733, // base page height

      size: "stretch",
      // set threshold values:
      minWidth: 315,
      maxWidth: 1000,
      minHeight: 420,
      maxHeight: 1350,

      maxShadowOpacity: 0.5, // Half shadow intensity
      showCover: true,
      mobileScrollSupport: false // disable content scrolling on mobile devices
    });
  
    pageFlip.loadFromHTML(document.querySelectorAll('.page'));

    document.querySelector(".page-total").innerText = pageFlip.getPageCount();
    document.querySelector(
        ".page-orientation"
    ).innerText = pageFlip.getOrientation();

    document.querySelector(".btn-prev").addEventListener("click", () => {
        pageFlip.flipPrev(); // Turn to the previous page (with animation)
    });

    document.querySelector(".btn-next").addEventListener("click", () => {
        pageFlip.flipNext(); // Turn to the next page (with animation)
    });

    // triggered by page turning
    pageFlip.on("flip", (e) => {
        document.querySelector(".page-current").innerText = e.data + 1;
    });

    // triggered when the state of the book changes
    pageFlip.on("changeState", (e) => {
        document.querySelector(".page-state").innerText = e.data;
    });

    // triggered when page orientation changes
    pageFlip.on("changeOrientation", (e) => {
        document.querySelector(".page-orientation").innerText = e.data;
    });
  }
}

export default App;
