import reactNativeConfig from '@react-native/eslint-config/flat';
import prettierConfig from 'eslint-config-prettier/flat';
import prettierPlugin from 'eslint-plugin-prettier';

export default [
  {
    ignores: [
      '**/node_modules/**',
      'dist/**',
      '**/build/**',
      'example/android/**',
      'example/ios/**',
      'example/vendor/**',
      'example-expo53/android/**',
      'example-expo53/ios/**',
      'coverage/**',
      '.yarn/**',
    ],
  },

  ...reactNativeConfig,

  // Turn off stylistic rules that conflict with Prettier, then let
  // eslint-plugin-prettier report formatting as lint errors.
  // `@react-native/eslint-config` no longer bundles eslint-plugin-prettier
  // (it did up to 0.73.x), so it has to be registered explicitly here.
  prettierConfig,
  {
    plugins: { prettier: prettierPlugin },
    rules: {
      'prettier/prettier': [
        'error',
        {
          quoteProps: 'consistent',
          singleQuote: true,
          tabWidth: 2,
          trailingComma: 'es5',
          useTabs: false,
        },
      ],
      'react-native/no-inline-styles': 'off',
    },
  },
];
