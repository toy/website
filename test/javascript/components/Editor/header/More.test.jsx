import React from 'react'
import { render, fireEvent, waitFor, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { More } from '../../../../../app/javascript/components/editor/header/More'

test('hides panel after clicking on revert button', async () => {
  const onRevert = () => {}
  render(<More onRevertToLastIteration={onRevert} />)

  fireEvent.click(screen.getByAltText('Open more options'))
  fireEvent.click(screen.getByText('Revert to last iteration'))

  await waitFor(() => {
    expect(
      screen.queryByText('Revert to last iteration')
    ).not.toBeInTheDocument()
  })
})
