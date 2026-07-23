---
name: Lost & Found Bangladesh
colors:
  surface: '#f7f9fb'
  surface-dim: '#d8dadc'
  surface-bright: '#f7f9fb'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f4f6'
  surface-container: '#eceef0'
  surface-container-high: '#e6e8ea'
  surface-container-highest: '#e0e3e5'
  on-surface: '#191c1e'
  on-surface-variant: '#434655'
  inverse-surface: '#2d3133'
  inverse-on-surface: '#eff1f3'
  outline: '#737686'
  outline-variant: '#c3c6d7'
  surface-tint: '#0053db'
  primary: '#004ac6'
  on-primary: '#ffffff'
  primary-container: '#2563eb'
  on-primary-container: '#eeefff'
  inverse-primary: '#b4c5ff'
  secondary: '#00687a'
  on-secondary: '#ffffff'
  secondary-container: '#57dffe'
  on-secondary-container: '#006172'
  tertiary: '#006056'
  on-tertiary: '#ffffff'
  tertiary-container: '#007b6e'
  on-tertiary-container: '#b1fff1'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dbe1ff'
  primary-fixed-dim: '#b4c5ff'
  on-primary-fixed: '#00174b'
  on-primary-fixed-variant: '#003ea8'
  secondary-fixed: '#acedff'
  secondary-fixed-dim: '#4cd7f6'
  on-secondary-fixed: '#001f26'
  on-secondary-fixed-variant: '#004e5c'
  tertiary-fixed: '#71f8e4'
  tertiary-fixed-dim: '#4fdbc8'
  on-tertiary-fixed: '#00201c'
  on-tertiary-fixed-variant: '#005048'
  background: '#f7f9fb'
  on-background: '#191c1e'
  surface-variant: '#e0e3e5'
typography:
  display-lg:
    fontFamily: Inter
    fontSize: 57px
    fontWeight: '700'
    lineHeight: 64px
    letterSpacing: -0.25px
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
  title-lg:
    fontFamily: Inter
    fontSize: 22px
    fontWeight: '600'
    lineHeight: 28px
  title-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 24px
    letterSpacing: 0.15px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
    letterSpacing: 0.5px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
    letterSpacing: 0.25px
  label-lg:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
    letterSpacing: 0.1px
  label-sm:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.5px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 8px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  2xl: 48px
  margin-mobile: 16px
  margin-tablet: 24px
  gutter: 16px
---

## Brand & Style
The design system for this product is centered on **Professional Minimalism** with a **Premium Glassmorphic** edge. It is designed to evoke feelings of reliability, efficiency, and calm during the stressful experience of losing or finding items. 

The aesthetic blends the structured reliability of Material 3 with high-end editorial flair. By utilizing heavy whitespace, soft gradients, and subtle translucency, the UI moves beyond functional utility into a sophisticated digital environment. The target audience includes urban professionals and digital natives in Bangladesh who value speed, clarity, and a modern aesthetic.

## Colors
The palette is rooted in a professional "Trust Blue," supported by energetic Cyans and Teals to signify movement and discovery. 

- **Primary & Secondary:** Used for high-emphasis actions, active states, and brand-defining moments like the "Report Found Item" flow.
- **Glass Effects:** In light mode, use a white base with 70-80% opacity and a 20px backdrop blur. In dark mode, use the dark background color at 60% opacity.
- **Surface Strategy:** Surfaces are not just flat colors; they utilize subtle linear gradients (e.g., Primary to Secondary at 10% opacity) to provide a premium, dynamic feel.

## Typography
The system uses **Inter** for its systematic, utilitarian, and clean profile, ensuring high legibility in data-heavy list views. 

- **Hierarchy:** Large bold titles (Display and Headline levels) should be used for welcome screens and category headers. 
- **Scale:** On mobile devices, ensure `headline-lg` scales down to the mobile-specific token to prevent awkward line breaks.
- **Emphasis:** Use semi-bold weights for interactive labels and "Title" roles to distinguish them clearly from descriptive body text.

## Layout & Spacing
The layout follows a strict **8px grid system** to maintain mathematical harmony across all components.

- **Grid:** Use a fluid column system. For mobile, a 4-column grid with 16px margins; for tablet, an 8-column grid with 24px margins.
- **Containers:** Content is grouped into logical blocks with a consistent 16px padding inside cards.
- **Vertical Rhythm:** Use the `lg` (24px) spacing for separating major sections and `sm` (8px) for related items within a component.

## Elevation & Depth
Elevation is communicated through **Ambient Shadows** and **Glassmorphism**, rather than traditional high-contrast shadows.

- **Level 1 (Cards):** Soft, extra-diffused shadow. `Offset: (0, 4), Blur: 20px, Color: Primary-Color (10% opacity)`.
- **Level 2 (Modals/FAB):** Deeper shadow. `Offset: (0, 8), Blur: 30px, Color: Primary-Color (15% opacity)`.
- **Depth Metaphor:** Items higher in elevation should gain more transparency and a stronger backdrop blur to simulate physical "floating" over the background. Avoid harsh black shadows; always tint shadows with the primary blue color.

## Shapes
The shape language is organic and approachable, utilizing a high corner radius to soften the professional tone.

- **Small Components:** Checkboxes and small buttons use a 12px radius.
- **Standard Cards:** Use `radius-lg` (18px) for most content containers.
- **Primary Containers:** Use `radius-xl` (24px) for bottom sheets, large feature cards, and the Floating Action Button.

## Components
- **Buttons:** Primary buttons use a subtle horizontal gradient (Primary to Secondary). Use `radius-xl` for a pill-like appearance. High-emphasis buttons should have a slight glow effect (shadow with primary color).
- **Cards:** White or tinted surface with a 1px inner border (white at 20% opacity) to enhance the "glass" look. 
- **Floating Action Button (FAB):** Large, 24px rounded corners, utilizing the Primary-to-Secondary gradient. Positioned at the bottom-right for "Report Item."
- **Text Fields:** Filled style with a 16px radius. The background should be a slightly darker shade of the neutral color (#F1F5F9). On focus, the border transitions to Primary Blue.
- **Bottom Navigation:** Use a glassmorphic background blur with active icons highlighted by a soft teal glow.
- **Skeleton Loaders:** Shimmer effect using a gradient from #E2E8F0 to #F8FAFC to match the premium, airy aesthetic.
- **Chips:** Highly rounded (pill-shaped) with a Secondary-to-Accent soft tint for categories like "Electronics," "Pets," or "Documents."