const thisStorybookNftId = 0; // TODO: set dynamically (based on which storybook NFT is being loaded)

const storybookNFTs = [ // TODO: mockup NFT array (to hold all NFT data)
    {
    doublepages: [ // each entry will be rendered into one double page (image on the left page, prompt and story on the right page)
        {
            imageId: 494, // 0 - 494 (as there are 495 unique images)
            imageUrl: "./Charles_image_494.png",
            promptIndex: 0, // 0 - 9 (as there are 10 unique prompts per image)
            promptId: "494-0", // imageId-promptIndex
            prompt: "Charles woke up one morning to find a mysterious email", // text of the prompt (doesn't change)
            story: "Charles woke up one morning to find a mysterious email in his inbox. It was an invitation to a global crypto treasure hunt, where clues embedded in the blockchain led to hidden wallets full of tokens. Determined, Charles spent days deciphering cryptographic riddles and finally cracked the code. The wallet revealed a modest sum, but the thrill of the chase was the real reward.", // generated story, i.e. initially empty and to then be filled by user triggering story generation for this page
        },
        {
            imageId: 200,
            imageUrl: "./Charles_image_200.png",
            promptIndex: 9,
            promptId: "200-9",
            prompt: "Excitement filled Charles as he invested in a new, promising crypto project",
            story: "Excitement filled Charles as he invested in a new, promising crypto project. He watched as the value of his tokens skyrocketed. But one morning, a headline shook the crypto world: the project’s founders had vanished with millions. Charles logged into his wallet to find his tokens worthless. It was a lesson in the wild, unpredictable world of digital currency.",
        },
        {
            imageId: 3,
            imageUrl: "./Charles_image_3.png",
            promptIndex: 5,
            promptId: "3-5",
            prompt: "At a crypto conference, Charles overheard two experts",
            story: "At a crypto conference, Charles overheard two experts debating the future of a particular coin. Amused, he made a friendly wager with a fellow attendee on which expert would be right. Months later, as the coin doubled in value, Charles smiled at his small win—not for the money, but for the unexpected friendships made at that conference.",
        },
        {
            imageId: 44,
            imageUrl: "./Charles_image_44.png",
            promptIndex: 0,
            promptId: "44-0",
            prompt: "Charles was passionate about digital art",
            story: "Charles was passionate about digital art and proudly owned several unique NFTs. One night, he discovered that his NFT collection had been stolen from his wallet. Furious but determined, Charles worked with blockchain security experts to trace the theft. Eventually, he found the thief's address, and with evidence in hand, he reclaimed his prized digital artworks.",
        },
        {
            imageId: 95,
            imageUrl: "./Charles_image_95.png",
            promptIndex: 2,
            promptId: "95-2",
            prompt: "Charles had always wanted to make a difference in the world",
            story: "Charles had always wanted to make a difference in the world. When he heard of a decentralized charity project accepting crypto donations to support clean water initiatives, he didn’t hesitate. Converting a portion of his crypto into funding, he was thrilled to see reports of wells being built in rural areas. For Charles, crypto wasn’t just about making money; it was about making a meaningful impact.",
        },
    ],
    // additional NFT metadata
    },
    // more NFT entries
];

function getStorybookDataToDisplay(storybookNftId) { // TODO: mockup helper function to load data for storybook that will be displayed as pages
    return storybookNFTs[storybookNftId].doublepages;
};

document.addEventListener("DOMContentLoaded", function () {
    const storybookData = getStorybookDataToDisplay(thisStorybookNftId);

    const bookContainer = document.getElementById('book');

    storybookData.forEach((pageData, index) => {
        // Create the left page (image)
        const leftPage = document.createElement('div');
        leftPage.classList.add('page');
        leftPage.innerHTML = `
            <div class="page-content">
            <h2 class="page-header">Adventures with Charles</h2>
            <div class="charles-image" style="background-image: url('${pageData.imageUrl}');"></div>
            <div class="page-footer">${(index * 2) + 1}</div>
            </div>
        `;

        // Create the right page (prompt and story)
        const rightPage = document.createElement('div');
        rightPage.classList.add('page');
        rightPage.innerHTML = `
            <div class="page-content">
            <h2 class="page-header">Chapter ${index + 1}</h2>
            <h3 class="story-prompt">${pageData.prompt}</h3>
            <div class="story-text">${pageData.story}</div>
            <div class="page-footer">${(index + 1) * 2}</div>
            </div>
        `;

        // Append the left and right pages to the book container
        bookContainer.appendChild(leftPage);
        bookContainer.appendChild(rightPage);
    });

    // Add the page flip effect
    const pageFlip = new St.PageFlip(bookContainer, {
        width: 550,
        height: 733,
        size: "stretch",
        minWidth: 315,
        maxWidth: 1000,
        minHeight: 420,
        maxHeight: 1350,
        maxShadowOpacity: 0.9,
        showCover: false,
        mobileScrollSupport: false,
        flippingTime: 1800,
    });

    pageFlip.loadFromHTML(document.querySelectorAll('.page'));

    // Adjust the font size of the story elements depending on the story length
    const storyTexts = document.querySelectorAll(".story-text"); // Select all elements with class 'story-text'

    function adjustFontSize(element) {
        const maxLength = 406; // Maximum character length for the base font size
        const baseFontSize = 100; // Base font size in percentage

        const textLength = element.textContent.length;
        const fontSize = Math.max(baseFontSize - (textLength / maxLength) * 16, 55); // Calculate font size, minimum 55%
        element.style.fontSize = `${fontSize}%`;
    };

    storyTexts.forEach((storyText) => {
        adjustFontSize(storyText); // Adjust font size for each element
    });

    // iframe integration
    // Function to send current page data to the parent
    function sendPageData() {
        const currentPage = pageFlip.getCurrentPageIndex(); // Get the current page index (0-based), i.e. 0 - 9
        const totalPages = pageFlip.getPageCount(); // Get total pages

        const assetsIndex = currentPage / 2; // Convert to double page index to get correct entry from storybookNFTs.doublepages (0-based), i.e. 0 - 4
        
        const data = {
            storybookNftId: thisStorybookNftId,
            currentPage,
            currentDoublePage: assetsIndex,
            totalPages,
            imageId: storybookData[assetsIndex].imageId,
            imageUrl: storybookData[assetsIndex].imageUrl,
            promptIndex: storybookData[assetsIndex].promptIndex,
            promptId: storybookData[assetsIndex].promptId,
            prompt: storybookData[assetsIndex].prompt,
            //story: storybookData[assetsIndex].story,
        };

        // Post the message to the parent
        window.parent.postMessage(data, '*'); // TODO?: Replace '*' with specific origin for security
    };

    // Send page data whenever the parent requests it
    window.addEventListener('message', (event) => {
        // Validate the origin (TODO?: replace '*' with your expected origin for security)
        if (event.origin !== '*' && event.origin !== 'https://your-parent-domain.com') return;

        const { action } = event.data;

        if (action === 'getPageData') {
            sendPageData();
        };
    });

    /* pageFlip.on('flip', () => {
        sendPageData();
    }); */
});