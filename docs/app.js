// ============================================================
// SAPPHIRE+ SHOWCASE APP LOGIC
// Easy Devlog & Features Management
// ============================================================

// ==========================================
// 1. DEVLOG / CHANGELOG DATA (EDIT HERE TO ADD UPDATES)
// ==========================================
const devlogs = [
    {
        version: "v0.6.0",
        isLatest: true,
        tag: "Tactical & Mayhem Expansion",
        items: [
            { label: "Army of Jokers", desc: "Instantly converts all active cops across the heist into an army of friendly criminal minions with max minion limits bypassed." },
            { label: "Gage Package Collector", desc: "Instantly collects all hidden Gage Courier packages on the map with a single in-game menu action." },
            { label: "Instant Custody Breakout", desc: "Instantly trades and brings all downed/dead teammates and AI companions back from custody." },
            { label: "Clean All Corpses", desc: "Silently sweeps and cleans all dead bodies and leftover body bags across the map." },
            { label: "Ragdoll Space Program", desc: "Multiplies ragdoll death impulse physics to launch enemies into orbit upon lethal hits." },
            { label: "360 Sprinting", desc: "Enables omnidirectional sprinting in all directions (sideways, backwards) without breaking sprint." },
            { label: "Instant Melee Charge", desc: "Guarantees 100% full charged melee damage, range, and knockdown on instant tap." },
            { label: "Gas Mask & Anti-Flashbang", desc: "Grants complete immunity against flashbang blinding screens, audio ringing, and tear gas damage." }
        ]
    },
    {
        version: "v0.5.0",
        isLatest: false,
        tag: "Stealth & Pre-Planning Update",
        items: [
            { label: "Multi-Pickup", desc: "Pick up multiple keycards, planks, C4, and thermite with accurate HUD quantity badges. Solo Shadow Raid vault is now fully accessible." },
            { label: "Infinite Camera Loop", desc: "Extended tape loop duration to 99,999 seconds with full Extra Heist Info (EHI) timer synchronization." },
            { label: "Minimum Detection Risk", desc: "Forces 3 Detection Risk (minimum suspicion offset) regardless of equipped armor (ICTV) or heavy weapons." },
            { label: "Unlimited Pre-Planning Favors", desc: "Removed favor budget limits and eliminated asset favor and offshore cash costs." },
            { label: "Drills Overhaul & Auto-Cooker", desc: "Added instant drills, zero-jam protection, and automatic meth lab chemical detection." }
        ]
    },
    {
        version: "v0.4.0",
        isLatest: false,
        tag: "Carry, Stealth & QoL Expansion",
        items: [
            { label: "Carry Overhaul", desc: "Added sprint-with-carry, jump height normalization, and eliminated movement speed penalties on heavy loot bags and body bags." },
            { label: "Bag Throw Distance", desc: "Added customizable slider (1.0x - 5.0x) for extended loot bag tossing." },
            { label: "Stealth & Pagers", desc: "Added AI Can't Alarm, Auto-Answer Pagers, and configurable Random Pagers removal chance slider." },
            { label: "Interactions", desc: "Added extended interaction distance multiplier (up to 5x) and instant interaction / no cooldown toggle." },
            { label: "Survivability", desc: "Added No Fall Damage, Bag Damage Absorption, and Armor Movement Penalty bypass." },
            { label: "DLC Unlocks", desc: "Enabled free hosting for all DLC heists directly from Crime.net." },
            { label: "Smart Safe Mode", desc: "Automatically neutralizes cheat-tier features when joining other players' multiplayer lobbies." }
        ]
    },
    {
        version: "v0.1.0",
        isLatest: false,
        tag: "Initial Release",
        items: [
            { label: "Core Mod Framework", desc: "Core SuperBLT hook architecture, JSON configuration persistence, in-game hotkey toggle, and basic bag movement modifications." }
        ]
    }
];

// ==========================================
// 2. COMPLETE FEATURE MODULES DATA
// ==========================================
const features = [
    // --- TACTICAL IN-GAME MENU ACTIONS ---
    {
        title: "Army of Jokers (Auto-Convert)",
        category: "qol",
        tag: "Tactical Action",
        icon: "users",
        desc: "Instantly converts all active cops and SWAT units across the heist into friendly criminal Jokers with minion limits bypassed and friendly outlines applied."
    },
    {
        title: "Collect All Gage Packages",
        category: "stealth",
        tag: "Tactical Action",
        icon: "package-search",
        desc: "Instantly sweeps the entire map and collects all hidden Gage Courier packages (Green Mantis, Yellow Bull, Red Spider, Blue Eagle, Purple Snake) with one click."
    },
    {
        title: "Instant Custody Breakout",
        category: "qol",
        tag: "Tactical Action",
        icon: "user-check",
        desc: "Immediately trades and respawns all downed or dead human teammates and AI bot companions from custody without waiting for the assault break."
    },
    {
        title: "Clean All Corpses & Bags",
        category: "stealth",
        tag: "Tactical Action",
        icon: "sparkles",
        desc: "Silently sweeps and despawns all dead enemy bodies, civilian corpses, and leftover body bags across the map to prevent patrolling guards from raising alarms."
    },
    {
        title: "Teleport Loot & Bag Ejector",
        category: "carry",
        tag: "Tactical Action",
        icon: "box",
        desc: "Opens all crates and lockers, packs all unbagged loose loot into carry bags, and batches/ejects them forward in your line of sight."
    },
    {
        title: "Unlock All Doors & Gates",
        category: "stealth",
        tag: "Tactical Action",
        icon: "unlock",
        desc: "Instantly unlocks and opens all standard doors, security rooms, keycard readers, and iron cage gates across the entire heist map."
    },
    {
        title: "Tie All Civilians",
        category: "stealth",
        tag: "Tactical Action",
        icon: "user-minus",
        desc: "Instantly intimidates and restrains all civilians across the map with cable ties, forcing them to the floor with cable tie limits bypassed."
    },
    {
        title: "Instant Team Revive",
        category: "qol",
        tag: "Tactical Action",
        icon: "heart-pulse",
        desc: "Instantly revives yourself and all downed human teammates and AI bot companions across the map to full standing health."
    },
    {
        title: "Wipe All Enemies & Cameras",
        category: "stealth",
        tag: "Tactical Action",
        icon: "skull",
        desc: "Silently despawns all guards, Murkywater security, and cops across the map while shutting down all active security cameras without alarms or pagers."
    },

    // --- COMBAT & MOVEMENT OVERHAULS ---
    {
        title: "Ragdoll Space Program",
        category: "carry",
        tag: "Physics",
        icon: "rocket",
        desc: "Multiplies ragdoll death impulse physics by 35x-50x, launching killed cops and SWAT units flying into the sky and out of windows."
    },
    {
        title: "360° Sprinting (Omnidirectional)",
        category: "carry",
        tag: "Movement",
        icon: "compass",
        desc: "Sprint at full speed in any direction, including backwards and sideways, without breaking into standard walk mode."
    },
    {
        title: "Instant Melee Charge",
        category: "carry",
        tag: "Combat",
        icon: "swords",
        desc: "Every melee tap strikes with 100% full charged damage, extended attack reach, and guaranteed knockdown instantly without charging."
    },
    {
        title: "Gas Mask & Anti-Flashbang",
        category: "qol",
        tag: "Protection",
        icon: "shield-alert",
        desc: "Grants complete immunity against flashbang whiteout screens, audio ringing, and tear gas damage ticks."
    },
    {
        title: "Carry Weight & Sprint Overhaul",
        category: "carry",
        tag: "Carry",
        icon: "zap",
        desc: "Sprint at full speed while carrying gold, artifacts, or nuclear warheads. Completely removes the vanilla sluggish walk/sprint penalties on heavy bags."
    },
    {
        title: "Bag Throw Distance Multiplier",
        category: "carry",
        tag: "Carry",
        icon: "arrow-up-right",
        desc: "Customizable slider (0.1x to 20.0x) to fling loot bags over rooftops, across broad courtyards, or directly into escape vehicles from afar."
    },
    {
        title: "Jump Height with Heavy Bags",
        category: "carry",
        tag: "Carry",
        icon: "chevrons-up",
        desc: "Maintains full jumping height while carrying any loot type, allowing you to vault over fences, windows, and obstacles effortlessly."
    },
    {
        title: "Affect Body Bags",
        category: "carry",
        tag: "Carry",
        icon: "user-x",
        desc: "Applies all sprint, jump, and movement speed multipliers to civilian and security guard body bags as well."
    },
    {
        title: "Ignore Armor Movement Penalty",
        category: "carry",
        tag: "Movement",
        icon: "shield",
        desc: "Eliminates movement speed, stamina drain, and agility penalties when wearing heavy ballistic vests and the Improved Combined Tactical Vest (ICTV)."
    },
    {
        title: "No Fall Damage",
        category: "carry",
        tag: "Movement",
        icon: "activity",
        desc: "Eliminates all fall damage when jumping from roofs, crane platforms, or balconies while securing loot bags."
    },
    {
        title: "Bag Damage Absorption",
        category: "carry",
        tag: "Carry",
        icon: "shield-plus",
        desc: "Grants customizable damage resistance (up to 100%) while carrying loot bags, giving you extra survivability during intense extractions."
    },
    {
        title: "Infinite Stamina",
        category: "carry",
        tag: "Movement",
        icon: "gauge",
        desc: "Sprint indefinitely without your stamina meter depleting or your character running out of breath."
    },

    // --- STEALTH TOOLS ---
    {
        title: "Multi-Pickup (Keycards & Consumables)",
        category: "stealth",
        tag: "Stealth",
        icon: "key-round",
        desc: "Stack consumable mission items including Keycards, Planks, C4, and Thermite without hitting inventory limits. Essential for solo stealth on maps like Shadow Raid vault."
    },
    {
        title: "Infinite Camera Loop",
        category: "stealth",
        tag: "Stealth",
        icon: "cctv",
        desc: "Extends tape loop duration to 99,999 seconds. Fully synced with Extra Heist Info (EHI) and HUD timer overlays. Loop a camera once and ignore it for the rest of the heist."
    },
    {
        title: "Minimum Detection Risk (Always 3)",
        category: "stealth",
        tag: "Stealth",
        icon: "eye-off",
        desc: "Forces detection risk to the engine minimum (3 Detection Risk) regardless of what heavy armor (ICTV) or weapons you wear. Grants maximum Sneaky Bastard & Low Blow bonuses."
    },
    {
        title: "AI Can't Alarm",
        category: "stealth",
        tag: "Stealth",
        icon: "bell-off",
        desc: "Prevents guards, civilians, and cops from raising the alarm, shooting panic flares, or triggering emergency calls."
    },
    {
        title: "Random Pagers / No Pager Chance",
        category: "stealth",
        tag: "Stealth",
        icon: "radio",
        desc: "Configurable slider (1% - 100%) that gives a random chance for eliminated security guards to drop no pager at all, preserving your 4-pager limit."
    },
    {
        title: "Auto-Answer Pagers",
        category: "stealth",
        tag: "Stealth",
        icon: "phone-call",
        desc: "Automatically answers pagers immediately when a security guard is neutralized, preventing missed pagers while managing stealth objectives."
    },

    // --- QUALITY OF LIFE & PRE-PLANNING ---
    {
        title: "Drills Never Jam & Instant Drills",
        category: "qol",
        tag: "Drills",
        icon: "cpu",
        desc: "Prevents drills, saws, and hacking devices from jamming, and optionally completes them in 0.01 seconds."
    },
    {
        title: "Auto-Cooker (Cook Off & Rats)",
        category: "qol",
        tag: "Chemistry",
        icon: "flask-conical",
        desc: "Listens to Bain & Locke voice cues and automatically adds the correct chemical ingredient (Mu / Cs / HCl) without delay."
    },
    {
        title: "Unlimited Pre-Planning Favors",
        category: "qol",
        tag: "Pre-Planning",
        icon: "wallet",
        desc: "Removes pre-planning favor budget limits and reduces favor and offshore cash costs to $0. Purchase every camera feed, spycam, dead drop, and escape plan."
    },
    {
        title: "Extended Interaction Range",
        category: "qol",
        tag: "QoL",
        icon: "maximize-2",
        desc: "Increases interaction distance up to 30x, allowing you to pick locks, grab keycards, and interact through grates from safe cover."
    },
    {
        title: "Interaction Speed Reduction",
        category: "qol",
        tag: "QoL",
        icon: "timer",
        desc: "Reduces interaction timer duration linearly (0% = vanilla, 50% = twice as fast, 100% = instant) on all mission objectives."
    },
    {
        title: "Unlock All DLC Heists for Hosting",
        category: "qol",
        tag: "Crime.net",
        icon: "unlock",
        desc: "Unlocks every paid DLC heist on Crime.net so you can host any mission in PAYDAY 2 for your squad without purchasing DLC packs."
    },
    {
        title: "Multiplayer Safe Mode",
        category: "qol",
        tag: "Core",
        icon: "shield-check",
        desc: "Automatically neutralizes cheat-tier features when joining other hosts' multiplayer lobbies to protect against anti-cheat kicks and desyncs."
    }
];

// ==========================================
// 3. UI RENDERING & EVENT HANDLING
// ==========================================
document.addEventListener('DOMContentLoaded', () => {
    const changelogList = document.getElementById('changelogList');
    const featuresGrid = document.getElementById('featuresGrid');
    const filterButtons = document.querySelectorAll('.filter-btn');
    const versionPill = document.querySelector('.version-pill');

    // Auto-sync latest version to the navbar pill
    if (versionPill && devlogs.length > 0) {
        versionPill.textContent = devlogs[0].version;
    }

    // Render Devlog / Changelog
    function renderDevlogs() {
        if (!changelogList) return;
        changelogList.innerHTML = '';

        devlogs.forEach(entry => {
            const card = document.createElement('div');
            card.className = `log-entry ${entry.isLatest ? 'latest' : ''}`;

            const itemsHtml = entry.items.map(item => `
                <li><strong>${item.label}:</strong> ${item.desc}</li>
            `).join('');

            card.innerHTML = `
                <div class="log-header">
                    <div class="log-version-row">
                        <span class="log-version">${entry.version}</span>
                        ${entry.isLatest ? '<span class="badge-current">CURRENT RELEASE</span>' : ''}
                    </div>
                    <span class="log-date">${entry.tag}</span>
                </div>
                <ul class="log-items">
                    ${itemsHtml}
                </ul>
            `;
            changelogList.appendChild(card);
        });
    }

    // Render Feature Cards
    function renderFeatures(filter = 'all') {
        if (!featuresGrid) return;
        featuresGrid.innerHTML = '';

        const filtered = filter === 'all'
            ? features
            : features.filter(f => f.category === filter);

        filtered.forEach(feature => {
            const card = document.createElement('div');
            card.className = 'feature-card';
            card.setAttribute('data-category', feature.category);

            card.innerHTML = `
                <div class="card-header">
                    <div class="card-icon-wrap">
                        <i data-lucide="${feature.icon}"></i>
                    </div>
                    <span class="card-tag">${feature.tag}</span>
                </div>
                <h3 class="card-title">${feature.title}</h3>
                <p class="card-desc">${feature.desc}</p>
            `;
            featuresGrid.appendChild(card);
        });

        // Initialize Lucide Icons for dynamic content
        if (typeof lucide !== 'undefined' && lucide.createIcons) {
            lucide.createIcons();
        }
    }

    // Filter Buttons Click Handling
    filterButtons.forEach(btn => {
        btn.addEventListener('click', () => {
            filterButtons.forEach(b => b.classList.remove('active'));
            btn.classList.add('active');
            const category = btn.getAttribute('data-filter');
            renderFeatures(category);
        });
    });

    // Initial Renders
    renderDevlogs();
    renderFeatures('all');
});
